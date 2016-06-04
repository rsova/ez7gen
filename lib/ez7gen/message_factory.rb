require 'ruby-hl7'
require_relative '../ez7gen/profile_parser'
require_relative '../ez7gen/structure_parser'
require_relative '../ez7gen/service/segment_generator'
require_relative '../ez7gen/service/template_generator'
require_relative '../ez7gen/service/segment_picker'
require_relative '../ez7gen/service/utils'

class MessageFactory
  include Utils
  attr_accessor :templatePath #TODO: refactor
  # attr_accessor :std; :version; :event; :version_store; :loadFactor;

  def initialize(args)
    @attributes_hash = args
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    @loadFactor ||= nil

  end

  # main factory method
  def generate_message()

    # get message structure from the schema file for message type and version
    parser = ProfileParser.new(@attributes_hash)
    structure = parser.get_message_definition()

    # brake message structure into segments, handle groups of segments
    structParser = StructureParser.new()
    structParser.process_segments(structure)

    # select segments to build, keep required and z segments, random pick optional segments
    profile = structure.split('~')
    segment_picker = SegmentPicker.new(profile, structParser.encodedSegments, @loadFactor)
    segments = segment_picker.pick_segments_to_build()

    # set primary parser for base schema
    parsers = {PRIMARY => parser}

    # if this is a custom Z segment, add the base parser
    # if(version !='2.4')
    # check if current version is not the base version, find the base version and add use it as a base parser
    if(!is_base?(@version))
      add_base_parser(parsers)
    end

    # configure a segment generator
    baseVersion = @std
    segmentGenerator = SegmentGenerator.new(baseVersion, @event, parsers)

    # msh segment configured by hand, due to many requirements that only apply for this segment
    @hl7Msg = HL7::Message.new
    @hl7Msg << segmentGenerator.init_msh()


    #iterate over selected segments and build the entire message
    # segments.each.with_index(){ |segment, idx|
    segments.each{ |segment|
      segmentGenerator.generate(@hl7Msg, segment, parsers)
     }

    return @hl7Msg
  end

  # factory method
  def generate_message_from_template()

    # if (@templatePath)
    #   templatePath = @templatePath
    # end

    # get message structure from the schema file for message type and version
    parser = ProfileParser.new(@attributes_hash)
    # structure = parser.get_message_definition()

    # brake message structure into segments, handle groups of segments
    # structParser = StructureParser.new()
    # structParser.process_segments(structure)

    # select segments to build, keep required and z segments, random pick optional segments
    # profile = structure.split('~')
    # segment_picker = SegmentPicker.new(profile, structParser.encodedSegments, @loadFactor)
    # segments = segment_picker.pick_segments_to_build()

    # set primary parser for base schema
    parsers = {PRIMARY => parser}

    # if this is a custom Z segment, add the base parser
    # if(version !='2.4')
    # check if current version is not the base version, find the base version and add use it as a base parser
    if(!is_base?(@version))
      add_base_parser(parsers)
    end

    # configure a segment generator
    baseVersion = @std

    templateGenerator = TemplateGenerator.new(templatePath, parsers)
    @hl7Msg = HL7::Message.new

    template = templateGenerator.build_template_metadata()
    templateGenerator.generate(@hl7Msg, template)

    # msh segment configured by hand, due to many requirements that only apply for this segment
    # @hl7Msg << segmentGenerator.init_msh()

    # segments = template.keys
    #
    #   # f = template[s]
    #   #
    #   # dt_partials = []
    #   # dt_partials << break_to_partial(f)
    #   #
    #   # # flds[f[:Pos].to_i] = dt_partials.join('^')
    #   # flds << dt_partials.join('|')
    #   segments.each{ |segment|
    #     segmentGenerator.generate(@hl7Msg, segment, parsers)
    #   }

    # }


    # #iterate over selected segments and build the entire message
    # # segments.each.with_index(){ |segment, idx|
    # segments.each{ |segment|
    #   segmentGenerator.generate(@hl7Msg, segment, parsers)
    #  }

    return @hl7Msg
  end

  def is_base?(version)
    isBase = @version_store.find { |s| s[:std] == @std }[:profiles].find { |p| p[:doc] == version }[:std]
  end

  # Add parser for base version of schema
  def add_base_parser(parsers)
    # find version for base standard version - standard with 'std' attribute
  v_base = @version_store.find { |s| s[:std] == @std }[:profiles].find { |p| p[:std]!=nil }[:doc]
    v_base_hash = @attributes_hash.clone()
    v_base_hash[:version] = v_base
    parsers[BASE]= ProfileParser.new(v_base_hash)
  end

  def self.to_arr(hl7Msg)
    arr = []
    hl7Msg.each{|it| arr << it.to_s.gsub("\r","\n")}
    return arr
  end

  # Identify segment as a part of a group
  def in_group?(groups, idx)
    is_in_group = !groups.select { |group| group.cover?(idx) }.empty?
    # p is_in_group
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