require 'ruby-hl7'
require "benchmark"
require "celluloid"

require_relative '../lib/ez7gen/profile_parser'
require_relative '../lib/ez7gen/service/segment_generator'
require_relative '../lib/ez7gen/service/segment_picker'
require_relative '../lib/ez7gen/service/utils'

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

     segments.each(){ |segment|
      #puts segment
      attributes = parsers[Utils.getTypeByName(segment)].getSegmentStructure(Utils.noBaseName(segment))
      #puts attributes
      hl7Msg = segmentGenerator.generate(hl7Msg, segment, attributes)
    }
    puts hl7Msg
     }

