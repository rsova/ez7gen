require 'ruby-hl7'
require 'date'
require 'benchmark'

require_relative 'type_aware_field_generator'
require_relative 'utils'

class SegmentGenerator
  @@maxReps = 2
  @@random = Random.new

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
  def initMsh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars ='^~\&'
    msh.sending_app = 'Sending App'
    msh.sending_facility = 'Sending Facility'
    msh.recv_app = "HL7 Generator"
    msh.recv_facility = "MARM"
    msh.processing_id = 'P'#@fieldGenerators['primary'].ID({},true)
    msh.version_id = '2.4'
    msh.security = @fieldGenerators['primary'].ID({})
    msh.message_type = @event.sub('_','^')<<'^'<<@event
    msh.time =  DateTime.now.strftime('%Y%m%d%H%M%S.%L')
    msh.message_control_id = @fieldGenerators['primary'].ID({},true)
    msh.seq = @fieldGenerators['primary'].ID({:required=>'O'})
    msh.continue_ptr = @fieldGenerators['primary'].ID({:required=>'O'})
    msh.accept_ack_type = @fieldGenerators['primary'].ID({:required=>'O', :codetable=>'155'})
    msh.country_code = @fieldGenerators['primary'].ID({:required=>'0', :codetable=>'399'})
    msh.charset = @fieldGenerators['primary'].ID({:required=>'0', :codetable=>'211'})
    #Table 296 Primary Language has no suggested values.  The field will be populated with values from the Primary Language table in the properties file. Example value: EN^English
    msh.principal_language_of_message ='EN^English'
    msh.alternate_character_set_handling_scheme = @fieldGenerators['primary'].ID({:required=>'O', :codetable=>'356'})
    # 21	Conformance Statement ID
    msh.e20 =  @fieldGenerators['primary'].ID({:required=>'O'})

    return msh
  end

  #generate test message using
  def generate( message,  segment,  attributes)

    isRep = isSegmentRepeated(segment)
    segmentName = Utils.getSegmentName(segment)

    # decide if segment needs to repeat and how many times
    totalReps = (isRep)? @@random.rand(1.. @@maxReps) : 1 # between 1 and maxReps

    totalReps.times do |i|
      # seg = (isRep)?message."get$segmentName"(i) :message."get$segmentName"()
      message << generateSegment(segmentName, attributes, (totalReps>1)?i+1:nil)
    end

    return message
  end

  # #generate test message using
  # def generateSegmentFields( segment, attributes)
  #   segmentName = Utils.getSegmentName(segment)
  #   generateSegment(segmentName, attributes)
  # end

  def isSegmentRepeated(segment)
    segment.include?("~{")
  end

  # generate a segment using Ensamble schema
  def generateSegment(segmentName, attributes, idx=nil)
    elements = generateSegmentElements(segmentName, attributes)

    # overrite ids for sequential repeating segments use ids
    elements[1] = (idx)? idx.to_s : elements[1]

    #generate segment using elements
    HL7::Message::Segment::Default.new(elements)
  end

  # use attributes to generate contents of a specific segment
  def generateSegmentElements(segmentName, attributes)

    fields =[]
    total = attributes.size()
    fieldGenerator=@fieldGenerators[Utils.getTypeByName(segmentName)]

    # generate segment attributes
    total.times do |i|
      fields << addField(attributes[i], fieldGenerator)
    end

    # add segment name to the beginning of the array
    fields.unshift(Utils.noBaseName(segmentName))
  end

  #adds a generated field based on data type
  def addField(attributes, fieldGenerator)

    dt = Utils.noBaseName(attributes[:datatype])
    # puts Utils.blank?(dt)?'~~~~~~~~~> data type is missing': dt
    if(['CK'].include?(dt))
      return nil
    else
    Utils.blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)
    end
  end

end