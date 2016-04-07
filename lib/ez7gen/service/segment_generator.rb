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


  # TODO: do I need accessors for version and event? refactor.
  attr_accessor :version; :event;

  # constructor
  def initialize(version, event, pp)
    @version = version
    @event = event

    #If there are multiple profile parsers, instantiate a generators for each
    @fieldGenerators = {}
    pp.each{|profileName, profiler| @fieldGenerators[profileName] = TypeAwareFieldGenerator.new(profiler)}
  end

  # initialize msh segment
  def init_msh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars ='^~\&'
    msh.sending_app = @fieldGenerators['primary'].HD({:codetable =>'361',:required =>'R'})
    msh.sending_facility = @fieldGenerators['primary'].HD({:codetable => '362', :required =>'R'})
    msh.recv_app = @fieldGenerators['primary'].HD({:codetable => '361', :required =>'R'})
    msh.recv_facility = @fieldGenerators['primary'].HD({:codetable => '362', :required =>'R'})
    msh.processing_id = 'P'#@fieldGenerators['primary'].ID({},true)
    #Per Galina, set version to 2.4 for all of vaz
    # msh.version_id = @@BASE_VER[@version]
    msh.version_id = @version
    msh.security = @fieldGenerators['primary'].ID({:required =>'O'})

    # Per Galina's requirement, fix for validation failure.
    # MSH.9.3 needs to be populated with the correct Message Structure values for those messages
    # that are the “copies” of the “original” messages.
    structType = @fieldGenerators['primary'].pp.get_message_structure(@event)
    msh.message_type = @event.sub('_','^')<<'^'<<structType

    msh.time =  DateTime.now.strftime('%Y%m%d%H%M%S.%L')
    msh.message_control_id = @fieldGenerators['primary'].ID({},true)
    msh.seq = @fieldGenerators['primary'].ID({:required=>'O'})
    msh.continue_ptr = @fieldGenerators['primary'].ID({:required=>'O'})
    msh.accept_ack_type = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'155'})
    msh.app_ack_type = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'155'})
    msh.country_code = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'399'})
    msh.charset = @fieldGenerators['primary'].ID({:required=>'R', :codetable=>'211'})
    #Table 296 Primary Language has no suggested values.  The field will be populated with values from the Primary Language table in the properties file. Example value: EN^English
    msh.principal_language_of_message ='EN^English'
    msh.alternate_character_set_handling_scheme = @fieldGenerators['primary'].ID({:required=>'O', :codetable=>'356'})
    # 21	Conformance Statement ID
    msh.e20 =  @fieldGenerators['primary'].ID({:required=>'O',:codetable=>'449'})

    return msh
  end

  # refactoring
  def gen(message, segment, parsers, isGroup)
    if(segment.kind_of?(Array))
      generate_group(message, segment, parsers)
    else
      generate_seg(message, segment, parsers, isGroup)
    end
  end

  def generate_seg(message,segment, parsers, isGroup)
    choiceParser = parsers[get_type_by_name(segment)]
    attributes = choiceParser.get_segment_structure(get_name_without_base(segment))
    generate(message, segment, attributes, isGroup)
  end

  # generate test message segment metadata
  def generate_group( message,  group,  parsers)
    #if Group Repeating
    isRep = group.instance_of?(RepeatingGroup)
    group.each{|seg|
        gen(message, seg, parsers,true)
    }
    # isRep = segment_repeated?(segment)
    # segmentName = get_segment_name(segment)
    #
    # # decide if segment needs to repeat and how many times
    # totalReps = (isRep)? @@random.rand(1.. @@maxReps) : 1 # between 1 and maxReps
    #
    # totalReps.times do |i|
    #   # seg = (isRep)?message."get$segmentName"(i) :message."get$segmentName"()
    #   message << generate_segment(segmentName, attributes, (totalReps>1)?i+1 :((isGroup)?1:nil))
    # end

    return message
  end

  # end

  # generate test message segment metadata
  def generate( message,  segment,  attributes, isGroup=false)

    isRep = segment_repeated?(segment)
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



  # #generate test message using
  # def generateSegmentFields( segment, attributes)
  #   segmentName = Utils.get_segment_name(segment)
  #   generate_segment(segmentName, attributes)
  # end

  def segment_repeated?(segment)
    segment.include?("~{")
  end

  # generate a segment using Ensemble schema
  def generate_segment(segmentName, attributes, idx=nil)
    elements = generate_segment_elements(segmentName, attributes)

    # overrite ids for sequential repeating segments use ids
      handle_set_ids(elements, idx, segmentName)

    #generate segment using elements
    HL7::Message::Segment::Default.new(elements)
  end

  def handle_set_ids(elements, idx, segmentName)
    set_id_fld = elements[1]
    #skip fields which are not IDs/numbers
    # idx_fld = (idx && is_number?(idx_fld)) ? idx.to_s : elements[1]
    # if(idx && is_number?(set_id_fld)) then set_id_fld = idx.to_s end

    #set-id field sometimes set to specific non numeric value, keep it, otherwise override if needed
    if(idx && (set_id_fld.empty? || is_number?(set_id_fld)))
      elements[1] = idx.to_s
    end

    #Set ID field in PID.1, AL1.1, DG1.1 etc. should have number 1 for the first occurrence of the segment.
    if (['PID', 'AL1', 'DG1'].include?(segmentName)) then
      elements[1] =(idx) ? idx.to_s : 1
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

    # dt = get_name_without_base(attributes[:datatype])
    if(type == Utils::BASE)
      attributes[:datatype] = get_name_without_base(attributes[:datatype])

      # if code table comes from the primary schema:  datatype => base:IS, codetable => VA026
      # add a parcer for primary to deal with code tables
      if (attributes[:codetable] && (type != get_type_by_name(attributes[:codetable])))
          baseParser = @fieldGenerators['primary'].pp
          fieldGenerator.instance_variable_set('@bp', baseParser)
      end
      attributes[:codetable] = get_name_without_base(attributes[:codetable])
    end

    dt = attributes[:datatype]
    # puts Utils.blank?(dt)?'~~~~~~~~~> data type is missing': dt
    if(['CK'].include?(dt))
      return nil
    else
      fld = blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)
    end
  end

end