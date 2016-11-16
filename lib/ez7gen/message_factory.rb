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
    # lookup for a template by name if client speified using a template
    @templatePath = (args[:use_template])? self.class.lookup_template_for_event(@std, @use_template):nil
    # @templatePath = self.class.lookup_template_for_event(@std, @event)

  end

  # look up for message template file for an event and standard: 2.4, ADT_A60
  def self.lookup_template_for_event(std, template)
    properties_file = File.expand_path('../resources/properties.yml', __FILE__)
    yml = YAML.load_file properties_file
    path = yml['web.install.dir']
    path = File.join(path, "config/templates/#{std}/#{template}")
    # path = File.join(path, "config/templates/#{std}/*#{event}*")
    # Dir.glob(path, File::FNM_CASEFOLD).sort.last
  end

  # main factory method
  def generate(useExVal=false)
    parsers = {}
    # get message structure from the schema file for message type and version
    parsers[PRIMARY] = ProfileParser.new(@attributes_hash)

    # check if current version is not the base version, find the base version and add use it as a base parser
    if(!is_base?(@version))# version is not standard != '2.4'
      parsers[BASE]= get_base_parser()
    end

    #useExVal can be passed from the client - future feature
    return (@templatePath)? generate_message_from_template(parsers, templatePath, useExVal) : generate_message(parsers)
  end

  # factory method to build message using schema
  def generate_message(parsers)

    # get message structure from the schema file for message type and version
    # use primary parser
    structure = parsers[PRIMARY].get_message_definition()

    # brake message structure into segments, handle groups of segments
    structParser = StructureParser.new()
    structParser.process_segments(structure)

    # select segments to build, keep required and z segments, random pick optional segments
    profile = structure.split('~')
    segment_picker = SegmentPicker.new(profile, structParser.encodedSegments, @loadFactor)
    segments = segment_picker.pick_segments_to_build()

    # configure a segment generator
    baseVersion = @std
    segmentGenerator = SegmentGenerator.new(baseVersion, @event, parsers)

    # msh segment configured by hand, due to many requirements that only apply for this segment
    hl7Msg = HL7::Message.new
    hl7Msg << segmentGenerator.init_msh
    # hl7Msg << segmentGenerator.init_msh(is_base?(@version))

    #iterate over selected segments and build the entire message
    segments.each{ |segment|
      segmentGenerator.generate(hl7Msg, segment, parsers)
     }

    return hl7Msg
  end

  # factory method to build message using MWB templates
  def generate_message_from_template(parsers, templatePath, useExVal)

    hl7Msg = HL7::Message.new

    templateGenerator = TemplateGenerator.new(templatePath, parsers)

    return templateGenerator.generate(hl7Msg, useExVal)

  end


  def is_base?(version)
    isBase = @version_store.find { |s| s[:std] == @std }[:profiles].find { |p| p[:doc] == version }[:std]
  end

  # Add parser for base version of schema
  def get_base_parser()
    # find version for base standard version - standard with 'std' attribute
    v_base = @version_store.find { |s| s[:std] == @std }[:profiles].find { |p| p[:std]!=nil }[:doc]
    v_base_hash = @attributes_hash.clone()
    v_base_hash[:version] = v_base
    ProfileParser.new(v_base_hash)
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