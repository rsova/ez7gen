require 'ruby-hl7'
require 'date'
require 'benchmark'

require_relative 'type_aware_field_generator'
require_relative '../../../lib/ez7gen/structure_parser'
require_relative 'utils'

class SegmentGenerator
  include Utils

  @@maxReps = 2
  @@random = Random.new
  @@BASE_VER={'2.4'=>'2.4','vaz2.4'=>'2.4'}
  @@SET_ID_PIECE = 1


  # TODO: do I need accessors for version and event? refactor.
  attr_accessor :version; :event;

  # constructor
  def initialize(version, event, pp)
    @version = version
    @event = event

    #If there are multiple profile parsers, instantiate a generators for each
    @fieldGenerators = {}
    pp.each{|profileName, profiler| @fieldGenerators[profileName] = TypeAwareFieldGenerator.new(profiler)}

    # for the custom messages, primary field generator has to look up base coded table values
    # add the parser on the fly to the field generator
    if(!@fieldGenerators[PRIMARY].pp.base?)
      baseParser = @fieldGenerators[BASE].pp
      @fieldGenerators[PRIMARY].instance_variable_set('@bp', baseParser)
    end

  end

  # initialize msh segment
  def init_msh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new

    #pick a field generator
    fieldGenerator = @fieldGenerators['primary']

    msh.enc_chars ='^~\&'
    msh.sending_app = fieldGenerator.HD({:codetable =>'361', :required =>'R'})
    msh.sending_facility = fieldGenerator.HD({:codetable => '362', :required =>'R'})
    msh.recv_app = fieldGenerator.HD({:codetable => '361', :required =>'R'})
    msh.recv_facility = fieldGenerator.HD({:codetable => '362', :required =>'R'})
    msh.processing_id = 'P'#@fieldGenerators['primary'].ID({},true)
    #Per Galina, set version to 2.4 for all of vaz
    # msh.version_id = @@BASE_VER[@version]
    msh.version_id = @version
    msh.security = fieldGenerator.ID({:required =>'O'})

    # Per Galina's requirement, fix for validation failure.
    # MSH.9.3 needs to be populated with the correct Message Structure values for those messages
    # that are the “copies” of the “original” messages.
    structType = fieldGenerator.pp.get_message_structure(@event)
    msh.message_type = @event.sub('_','^')<<'^'<<structType

    msh.time =  DateTime.now.strftime('%Y%m%d%H%M%S.%L')
    msh.message_control_id = fieldGenerator.ID({}, true)
    msh.seq = fieldGenerator.ID({:required=>'O'})
    msh.continue_ptr = fieldGenerator.ID({:required=>'O'})
    msh.accept_ack_type = fieldGenerator.ID({:required=>'R', :codetable=>'155'})
    msh.app_ack_type = fieldGenerator.ID({:required=>'R', :codetable=>'155'})
    msh.country_code = fieldGenerator.ID({:required=>'R', :codetable=>'399'})
    # msh.charset = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'211'})
    msh.charset = 'ASCII' # default value from codetable, change causes problems in validating messages in Ensemble
    #Table 296 Primary Language has no suggested values.  The field will be populated with values from the Primary Language table in the properties file. Example value: EN^English
    msh.principal_language_of_message ='EN^English'
    msh.alternate_character_set_handling_scheme = fieldGenerator.ID({:required=>'O', :codetable=>'356'})
    # 21	Conformance Statement ID
    msh.e20 =  fieldGenerator.ID({:required=>'O', :codetable=>'449'})

    return msh
  end

  # refactoring
  def generate(message, segment, parsers, isGroup=false)
    if(segment.kind_of?(Array))
      # handle group
      generate_group(message, segment, parsers)
    else
      # build_segment
      choiceParser = parsers[get_type_by_name(segment)]
      attributes = choiceParser.get_segment_structure(get_name_without_base(segment))
      generate_segment_in_context(message, segment, attributes, isGroup)

    end
  end

  # generate a group of segments in test message segment using metadata
  def generate_group( message,  group,  parsers)
    # generate each segment in the group
    totalReps = (group.instance_of?(RepeatingGroup))? (1..@@maxReps).to_a.sample: 1
    totalReps.times do |i|
      group.each{|seg| generate(message, seg, parsers, true) }
    end

    return message
  end

  # end

  # generate test message segment using metadata
  def generate_segment_in_context(message, segment, attributes, isGroup=false)
    isRep = is_segment_repeating?(segment)
    segmentName = get_segment_name(segment)

    # decide if segment needs to repeat and how many times
    # totalReps = (isRep)? @@random.rand(1.. @@maxReps) : 1 # between 1 and maxReps
    totalReps = (isRep)? (1..@@maxReps).to_a.sample: 1

    totalReps.times do |i|
      # seg = (isRep)?message."get$segmentName"(i) :message."get$segmentName"()
      #groupId = (totalReps>1)?i+1 :((isGroup)?1:nil)
      sharedGroupId = (isGroup)? i+1: nil
      message << generate_segment(segmentName, attributes, sharedGroupId)
    end

    return message
  end


  # #generate_segment_in_context test message using
  # def generateSegmentFields( segment, attributes)
  #   segmentName = Utils.get_segment_name(segment)
  #   generate_segment(segmentName, attributes)
  # end

  def is_segment_repeating?(segment)
    segment.include?("~{")
  end

  # generate a segment using Ensemble schema
  def generate_segment(segmentName, attributes, idx=nil)
    elements = generate_segment_elements(segmentName, attributes)
    # overrite ids for sequential repeating segments
    elements[@@SET_ID_PIECE] = handle_set_id(segmentName, attributes, idx) || elements[@@SET_ID_PIECE]

    #generate segment using elements
    HL7::Message::Segment::Default.new(elements)
  end

  def handle_set_id( segmentName, attributes, idx)

    #set-id field sometimes set to specific non numeric value, keep it, otherwise override if needed
    is_from_codetable = attributes.find { |p| p[:piece] == @@SET_ID_PIECE.to_s }[:codetable]
    if(!is_from_codetable) # ignore any value that generated using codetable
      #Set ID field in PID.1, AL1.1, DG1.1 etc. should have number 1 for the first occurrence of the segment.
      (idx) ? idx.to_s : (['PID', 'AL1', 'DG1'].include?(segmentName))? '1' :nil
    else
      nil
    end

  end

  # use attributes to generate contents of a specific segment
  def generate_segment_elements(segmentName, attributes)

    fields =[]
    total = attributes.size()
    # type = get_type_by_name(segmentName)
    # generate segment attributes
    total.times do |i|
      fields << add_field(attributes[i])
    end

    # add segment name to the beginning of the array
    fields.unshift(get_name_without_base(segmentName))
  end

  #adds a generated field based on data type
  def add_field(attributes)

    type = get_type_by_name(attributes[:datatype])
    fieldGenerator= @fieldGenerators[type]
    dt = get_name_without_base(attributes[:datatype])

    # # for messages with custom schemas use both parsers to look for codetable values
    # if(!@fieldGenerators[PRIMARY].pp.base? && attributes[:codetable] )
    #   # 1) if code table comes from the primary schema:  datatype => base:IS, codetable => VA026
    #   # add a parcer for primary to deal with code tables
    #   # 2) base type needs values from
    #   baseParser = @fieldGenerators[BASE].pp
    #   fieldGenerator.instance_variable_set('@bp', baseParser)
    # end
    # # dt = get_name_without_base(attributes[:datatype])
    # if(type == Utils::BASE)
    #   attributes[:datatype] = get_name_without_base(attributes[:datatype])
    #
    #   # if code table comes from the primary schema:  datatype => base:IS, codetable => VA026
    #   # add a parcer for primary to deal with code tables
    #   if (attributes[:codetable] && (type != get_type_by_name(attributes[:codetable])))
    #       baseParser = @fieldGenerators['primary'].pp
    #       fieldGenerator.instance_variable_set('@bp', baseParser)
    #   end
    #   if(attributes[:codetable])then get_name_without_base(attributes[:codetable]) end #TODO: Refactor
    # end

    # dt = attributes[:datatype]
    # puts Utils.blank?(dt)?'~~~~~~~~~> data type is missing': dt
    if(['CK'].include?(dt))
      return nil
    else
      fld = blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)
    end
  end

end