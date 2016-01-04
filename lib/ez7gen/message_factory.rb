require 'ruby-hl7'
require_relative '../ez7gen/profile_parser'
require_relative '../ez7gen/service/segment_generator'
require_relative '../ez7gen/service/segment_picker'
require_relative '../ez7gen/service/utils'

class MessageFactory
  include Utils

  def generate(version, event, loadFactor=nil)

    parser = ProfileParser.new(version, event)
    profile, encoded_segments = parser.get_segments()

    #Get list of non required segments randomly selected for this build
    segment_picker = SegmentPicker.new(profile, encoded_segments, loadFactor)
    segments = segment_picker.pick_segments()

    # set primary parser for base schema
    parsers = {PRIMARY => parser}

    # if this is a custom Z segment, add the base parser
    if(version !='2.4')
       parsers[BASE]= ProfileParser.new('2.4', event)
    end

    # configure a segment generator
    segmentGenerator = SegmentGenerator.new(version, event, parsers)

    # msh segment configured by hand, due to many requirements that only apply for this segment
    hl7Msg = HL7::Message.new
    hl7Msg << segmentGenerator.init_msh()

    # groups are elements that come together; they are  stored as Array
    # if groups are present among the segments, identify ranges of the groups
    groups = find_Groups(segments)

    # then collection of segments can flatten
    segments.flatten!

    #iterate over selected segments and build the entire message
    segments.each.with_index(){ |segment, idx|
      choiceParser = parsers[get_type_by_name(segment)]
      attributes = choiceParser.get_segment_structure(get_name_without_base(segment))
      segmentGenerator.generate(hl7Msg, segment, attributes, in_group?(groups, idx))
    }
     hl7Msg.to_s.gsub("\r","\n")
  end

  # Identify segment as a part of a group
  def in_group?(groups, idx)
    is_in_group = !groups.select { |group| group.cover?(idx) }.empty?
    p is_in_group
  end

  #find ranges of groups before segments collection containing groups can be flattened
  def find_Groups(segments)
    offset = 0
    # groups = segments.map.with_index { |it, idx| (it.instance_of? Array) ? ( groupLn=it.size-1;((offset+idx) .. (idx + offset=offset + groupLn)) ) : nil }.compact

    groups = segments.map.with_index { |it, idx|
      # groups of sequential segments stored as arrays of segments
      if (it.instance_of? Array)
        # calculate group range based on offset that affected flattening arrays of segments
        groupLen = it.size-1
        groupStart = offset + idx
        groupEnd = idx + offset = offset + groupLen # inline var assignment, just cause I can..
        (groupStart..groupEnd) # group range
      end
    }
    # get rid of nils
    groups.compact()
  end

end