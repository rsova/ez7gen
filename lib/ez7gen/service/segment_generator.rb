require 'ruby-hl7'
require 'date'
require_relative '../service/type_aware_field_generator'
require_relative 'utils'

class SegmentGenerator
  @@maxReps = 2
  @fieldGenerator
  @@random = Random.new

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

    # decide if segment needs to repeat and how many times
    totalReps = (isRep)? @@random.rand(1.. @@maxReps) : 1 # between 1 and maxReps

    totalReps.times do |i|
      # seg = (isRep)?message."get$segmentName"(i) :message."get$segmentName"()
      message << generateSegment(segmentName, attributes)
    end

    return message
  end

  def isSegmentRepeated(segment)
    # puts 'in isSegmentReapeated'
    return false
  end

  # generate a segment using Ensamble schema
  def generateSegment(segmentName, attributes)
    elements = generateSegmentElements(segmentName, attributes)
    HL7::Message::Segment::Default.new(elements)
  end

  # use attributes to generate contents of a specific segment
  def generateSegmentElements(segmentName, attributes)
    total = attributes.size()
    fields =[]

    total.times do |i|
      fields << addField(attributes[i])
    end
    # add segment name to the beginning of the array
    fields.unshift(segmentName)
  end

  #adds a generated field based on data type
  def addField(attributes)
    idx = attributes['piece']
    puts idx
    idx.to_i
    dt = attributes['datatype']
    puts dt
   @fieldGenerator.method(dt).call(attributes)
  end

end