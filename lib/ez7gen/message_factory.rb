require 'ruby-hl7'
require_relative '../ez7gen/profile_parser'
require_relative '../ez7gen/service/segment_generator'
require_relative '../ez7gen/service/segment_picker'
require_relative '../ez7gen/service/utils'

class MessageFactory

  def generate(version, event)

    parser = ProfileParser.new(version, event)
    segmentsMap = parser.getSegments()

    #Get list of non required segments randomly selected for this build
    segmentPicker = SegmentPicker.new(segmentsMap)
    segments = segmentPicker.pickSegments()

    # set primary parser for base schema
    parsers = { Utils.PRIMARY => parser }

    # if this is a custom Z segment, add the base parser
    if(version !='2.4')
       parsers[Utils.BASE]= ProfileParser.new('2.4', event)
    end

    # configure a segment generator
    segmentGenerator = SegmentGenerator.new(version, event, parsers)

    # msh segment configured by hand, due to many requirements that only apply for this segment
    hl7Msg = HL7::Message.new
    hl7Msg << segmentGenerator.initMsh()

    #iterate over selected segments and build the entire message
    segments.each(){ |segment|
      # groups of segments only repeated once for now
      if(segment=='{'||segment=='}')then next end

      choiceParser = parsers[Utils.getTypeByName(segment)]
      attributes = choiceParser.getSegmentStructure(Utils.noBaseName(segment))
      segmentGenerator.generate(hl7Msg, segment, attributes)
    }
    return hl7Msg
  end

end