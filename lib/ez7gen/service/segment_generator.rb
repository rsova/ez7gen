require 'ruby-hl7'
require 'date'
require 'benchmark'

require_relative 'type_aware_field_generator'
require_relative 'utils'

class SegmentGenerator
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
  def initMsh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new
    msh.enc_chars ='^~\&'
    msh.sending_app = @fieldGenerators['primary'].HD({:codetable =>'361',:required =>'R'})
    msh.sending_facility = @fieldGenerators['primary'].HD({:codetable => '362', :required =>'R'})
    msh.recv_app = @fieldGenerators['primary'].HD({:codetable => '361', :required =>'R'})
    msh.recv_facility = @fieldGenerators['primary'].HD({:codetable => '362', :required =>'R'})
    msh.processing_id = 'P'#@fieldGenerators['primary'].ID({},true)
    #Per Galina, set version to 2.4 for all of vaz
    msh.version_id = @@BASE_VER[@version]
    msh.security = @fieldGenerators['primary'].ID({:required =>'O'})

    # Per Galina's requirement, fix for validation failure.
    # MSH.9.3 needs to be populated with the correct Message Structure values for those messages
    # that are the “copies” of the “original” messages.
    structType = @fieldGenerators['primary'].pp.getMessageStructure(@event)
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

    #Set ID field in PID.1, AL1.1, DG1.1 etc. should have number 1 for the first occurrence of the segment.
    if(!idx && ['PID','AL1','DG1'].include?(segmentName))
      elements[1]=1
    end

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
      fld = Utils.blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)

    end
  end

end