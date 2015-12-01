require 'ruby-hl7'
require "benchmark"
require "celluloid"

require_relative '../lib/ez7gen/profile_parser'
require_relative '../lib/ez7gen/service/segment_generator'
require_relative '../lib/ez7gen/service/segment_picker'
require_relative '../lib/ez7gen/service/utils'

class SegmentGeneratorWorker
  include Celluloid

  def generate(segment, parsers, segmentGenerator)
    p = parsers[Utils.getTypeByName(segment)]
    #puts segment
    segmentName = Utils.noBaseName(segment)
    attributes = p.getSegmentStructure(segmentName)
    # segmentGenerator.generateSegmentFields(segment, attributes)
    segmentGenerator.generateSegment(segmentName, attributes)
    #puts attributes
  end

end


  version = "2.4"
  event = "ADT_A01"
  puts Benchmark.measure{

       parser = ProfileParser.new(version, event)
       segmentsMap = parser.getSegments()

       #Get list of non required segments randomly selected for this build
       segmentPicker = SegmentPicker.new(segmentsMap)
       segments = segmentPicker.pickSegments()
       parsers = { Utils.PRIMARY => parser }
       # if this is a custom segment, add base parser
       if(version !='2.4')
         parsers[Utils.BASE]= ProfileParser.new('2.4', event)
       end

       segmentGenerator = SegmentGenerator.new(version, event, parsers)

       #init messsage with msh segment
       hl7Msg = HL7::Message.new
       hl7Msg << segmentGenerator.initMsh()

       worker_pool = SegmentGeneratorWorker.pool(size: 20)
       futures = []

              segments.each(){ |segment|
                # mailer_pool.async.send_email(i)
                # worker_pool.async.generate(i)
                futures << worker_pool.future.generate(segment, parsers, segmentGenerator)
                # MailWorker.new().send_email(i)
              }



       total = futures.size
       puts total

       total.times do |i|
         # puts futures[i].value
         hl7Msg << futures[i].value
         puts '------------------------- \n'

       end

       puts hl7Msg
       futures.each{|it| puts it.value }
       }

