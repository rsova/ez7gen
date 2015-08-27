require 'ruby-hl7'
require_relative 'ProfileParser'
require_relative './service/SegmentPicker'
require_relative './service/SegmentGenerator'

class MessageFactory

  def generate(version, event)

    # 0: [[~PD1~], ~PD1~]
    # 1: [[~{~ROL~}~], ~{~ROL~}~]
    parser = ProfileParser.new(version, event)
    segmentsMap = parser.getSegments

    #Get list of non required segments randomly selected for this build
    segmentPicker = SegmentPicker.new(segmentsMap)
    segments = segmentPicker.pickSegments()

    segmentGenerator = SegmentGenerator.new(version, event, parser)
    #init messsage with msh segment
    hl7Msg = HL7::Message.new
    hl7Msg << segmentGenerator.initMsh()

    segments.each(){ |segment|
      puts segment
      attributes = parser.getSegmentStructure(segment)
      puts attributes
      hl7Msg = segmentGenerator.generate(hl7Msg, segment, attributes)
    }
  end



  # def generate(version, message)
  # 	 # create a message
  # 	msg = HL7::Message.new

  # 	# create a MSH segment for our new message
  # 	msh = HL7::Message::Segment::MSH.new
  # 	msh.recv_app = "easy7gen"
  # 	msh.recv_facility = "my office"
  # 	msh.processing_id = rand(10000).to_s
  # 	msh.sending_facility = 'facility 2'
  # 	msh.sending_app = 'integration app2'
  # 	msh.time =  DateTime.now
  # 	msh.version_id = "2.4"
  # 	#puts msh.methods
  # 	msg << msh # add the MSH segment to the message
  # 	seg = HL7::Message::Segment.new
  # 	seg.e0 = "PD"
  # 	#seg.e1 = '123'
  # 	seg.send :e1, "abc"

  # 	p seg
  # 	p seg.length

  # 	#fld = HL7::Message::SegmentFields.new
  # 	p fld

  # 	# for i in 1..5
  # 	# 	puts "e#{i}"
  # 	# 	seg.method("e1").call(i)
  # 	# 	#seg.@segments[i] = i
  # 	# end
  # 	msg << seg
  #	end
end