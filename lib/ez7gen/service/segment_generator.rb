require 'ruby-hl7'
require 'date'
require 'benchmark'

# require_relative 'type_aware_field_generator'
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
    pp.each{|profileName, parser|
      # helper parser for lookup in the other schema
      # when generating segments for custom (not base) ex VAZ2.4 the field generator will have to look in both schemas
      # to resolve types and coded tables value.
      # we will assign the other schema parser as a helper parser
      helper_parser = pp.select{|key, value| key != profileName}
      helper_parser = (helper_parser.empty?) ? nil: helper_parser.values.first
      begin
          require_relative "../../ez7gen/service/#{version}/field_generator"
          @fieldGenerators[profileName] = FieldGenerator.new( parser, helper_parser)
        rescue => e
          p e
          # @fieldGenerators[profileName] = TypeAwareFieldGenerator.new( parser, helper_parser)
      end
    }
    p @fieldGenerators
  end

  # initialize msh segment
  def init_msh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new

    #pick a field generator
    fieldGenerator = @fieldGenerators['primary']

    msh.enc_chars ='^~\&'
    # msh.sending_app = fieldGenerator.HD({:codetable =>'361', :required =>'R'})
    msh.sending_app = fieldGenerator.dt('HD',{:codetable =>'361', :required =>'R'})
    # msh.sending_facility = fieldGenerator.HD({:codetable => '362', :required =>'R'})
    msh.sending_facility = fieldGenerator.dt('HD',{:codetable => '362', :required =>'R'})
    msh.recv_app = fieldGenerator.dt('HD',{:codetable => '361', :required =>'R'})
    msh.recv_facility = fieldGenerator.dt('HD',{:codetable => '362', :required =>'R'})
    msh.processing_id = 'P'#@fieldGenerators['primary'].ID({},true)
    #Per Galina, set version to 2.4 for all of vaz
    # msh.version_id = @@BASE_VER[@version]
    msh.version_id = @version
    msh.security = fieldGenerator.dt('ID',{:required =>'O'})

    # Per Galina's requirement, fix for validation failure.
    # MSH.9.3 needs to be populated with the correct Message Structure values for those messages
    # that are the “copies” of the “original” messages.
    structType = fieldGenerator.pp.get_message_structure(@event)
    msh.message_type = @event.sub('_','^')<<'^'<<structType

    msh.time =  DateTime.now.strftime('%Y%m%d%H%M%S.%L')
    msh.message_control_id = fieldGenerator.dt('ID',{:required =>'R'})
    msh.seq = fieldGenerator.dt('ID',{:required=>'O'})
    msh.continue_ptr = fieldGenerator.dt('ID',{:required=>'O'})
    msh.accept_ack_type = fieldGenerator.dt('ID',{:required=>'R', :codetable=>'155'})
    msh.app_ack_type = fieldGenerator.dt('ID',{:required=>'R', :codetable=>'155'})
    msh.country_code = fieldGenerator.dt('ID',{:required=>'R', :codetable=>'399'})
    # msh.charset = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'211'})
    msh.charset = 'ASCII' # default value from codetable, change causes problems in validating messages in Ensemble
    #Table 296 Primary Language has no suggested values.  The field will be populated with values from the Primary Language table in the properties file. Example value: EN^English
    msh.principal_language_of_message ='EN^English'
    msh.alternate_character_set_handling_scheme = fieldGenerator.dt('ID',{:required=>'O', :codetable=>'356'})
    # 21	Conformance Statement ID
    msh.e20 =  fieldGenerator.dt('ID',{:required=>'O', :codetable=>'449'})

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

    if(blank?(type)) #safe handle missing data typetype
      attributes[:datatype] = 'ID'
      type = get_type_by_name(attributes[:datatype])
    end

    fieldGenerator= @fieldGenerators[type]
    data_type = get_name_without_base(attributes[:datatype])

    # puts Utils.blank?(dt)?'~~~~~~~~~> data type is missing': dt
    if(['CK'].include?(data_type))
      return nil
    else
      # fld = blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)
      fld = blank?(data_type)?nil :fieldGenerator.dt(data_type, attributes)
    end

  end

end