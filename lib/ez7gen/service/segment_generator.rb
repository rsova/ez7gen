require 'ruby-hl7'
require 'date'
require_relative '../service/type_aware_field_generator'
require_relative 'utils'

class SegmentGenerator
  @@maxReps = 5
  @fieldGenerator
  attr_accessor :version; :event;

  # constructor
  def initialize(version, event, pp)
    @version = version
    @event = event
    @fieldGenerator = TypeAwareFieldGenerator.new(pp)
  end

  # initialize msh segment
  def initMsh
    # create a MSH segment
    msh = HL7::Message::Segment::MSH.new
    msh.recv_app = "ez7gen"
    msh.recv_facility = "marm"
    msh.processing_id = rand(10000).to_s
    msh.sending_facility = 'facility 2'
    msh.sending_app = 'integration app2'
    msh.time =  DateTime.now
    # add the MSH segment to the message
    #msg << msh
    return msh
  end

  #generate test message using
  def generate( message,  segment,  attributes)

    isRep = isSegmentRepeated(segment)
    segmentName = Utils.getSegmentName(segment)

    #decide if segment needs to repeat and how many times
    totalReps = (isRep)? 1+Random.rand(@@maxReps):1

    totalReps.times do |i|
      # seg = (isRep)?message."get$segmentName"(i) :message."get$segmentName"()
      message << generateSegment(segmentName, attributes)
    end

    return message
  end

  def isSegmentRepeated(segment)
    puts 'in isSegmentReapeated'
    return false
  end

  # generate a segment using ensamble schema
  def generateSegment(segmentName, attributes)
    elements = generateSegmentElemens(segmentName, attributes)
    HL7::Message::Segment::Default.new(elements)
  end

  # use attributes to generate contents of a specific segment
  def generateSegmentElemens(segmentName, attributes)
    total = attributes.size()
    fields =[]
    total.times do |i|
      fields << addField(attributes[i])
    end
    return [segmentName]<<fields
  end

  #adds a generated field based on data type
  def addField(attributes)
    idx = attributes['piece']
    puts idx
    idx.to_i
    dt = attributes['datatype']
    puts dt
    # @fieldGenerator.EI(attributes)
    @fieldGenerator.method(dt).call(attributes)
  end
end