require_relative 'type_aware_field_generator.rb'
require_relative 'utils'

class TemplateGenerator
  include Utils
  #TODO: refactor in one place
  @@HAT = '^' # Component separator, aka hat
  @@SUB ='&' # Subcomponent separator

  # xml tags used in MWB schemas
  DATAVALUES = 'DataValues'
  COMPONENT = 'Component'
  SUBCOMPONENT = 'SubComponent'

  # use xml tags as symbols for name of collections
  COMP = COMPONENT.downcase.intern
  SUB = SUBCOMPONENT.downcase.intern

  # list of usages to be picked up, other ignored
  # @@USAGES = ['R','RE']
  USAGES_REQ = ['R']
  USAGES_OPT = ['RE']

  # initialise template generator with the path to template xml (MWB) and parcers
  def initialize(tempalte_path, pp)

    # parse template  TODO: refactor if not needed on class level move to 'build_template_metadata'
    text = File.path(tempalte_path)
    @xml = Ox.parse(IO.read(text))

    #If there are multiple profile parsers, instantiate a generators for each
    @fieldGenerators = {}
    # helper parser for lookup in the other schema
    # when generating segments for custom (not base) ex VAZ2.4 the field generator will have to look in both schemas
    # to resolve types and coded tables value.
    # we will assign the other schema parser as a helper parser

    pp.each{|profileName, parser|
      helper_parser = pp.select{|key, value| key != profileName }
      helper_parser = (helper_parser.empty?) ? nil: helper_parser.values.first
      # a = TypeAwareFieldGenerator.new( parser, helper_parser)
      #@fieldGenerators[profileName] = a
      @fieldGenerators[profileName] = TypeAwareFieldGenerator.new( parser, helper_parser)
    }

  end

  # build hl7 message using template as guideline
  # def generate(message, template, parsers, isGroup=false)
  def generate(message, useExVal)
    # read MWB xml file into collection of metadata for each segment
    metadata = build_metadata(useExVal)

    # segment names
    segments = metadata.keys

    # add each segment to message using template metadata
    segments.each{|segName|
      meta = metadata[segName]
      processed = process_partials(meta)
      message << generate_segment(segName, processed)
    }

    return message
  end

  # generate a segment using Ensemble schema
  def generate_segment(segmentName, attributes, idx=nil)
    # elements = generate_segment_elements(segmentName, attributes)
    attributes.unshift(get_name_without_base(segmentName))
    # elements = generate_segment_elements(segmentName, attributes)
    # overrite ids for sequential repeating segments
    # elements[@@SET_ID_PIECE] = handle_set_id(segmentName, attributes, idx) || elements[@@SET_ID_PIECE]

    #generate segment using elements
    if(segmentName == 'MSH')
      attributes.slice!(1)
      # one = two.first + two.last
      # attributes.insert(1,one)
    end
    return HL7::Message::Segment::Default.new(attributes)
  end

  # working with template hash brake field metadata to components and then to subcomponents
  def process_partials(item)
    partials = []

    # process each sub type
    if(item.kind_of? Array)

      item.each{|subType| # at this level we have components or subcomponents
        coll = subType[SUB] || subType # if subcomponents found process again
        unit = process_partials(coll)
        flag = (subType[SUB]) ? @@SUB : @@HAT
        partials[subType[:Pos].to_i] = unit.join(flag)
      }

    else
      # check for components first and then subcomponents
      coll = item[COMP] || item[SUB]
      if(coll)
        partials << process_partials(coll)
      else
        partials << build_partial_field_data(item)
      end
    end

    return partials

  end

  # convert
  def build_partial_field_data(item)
    # use the Example Value 'ExValue' defined in the xml file instead
    if(item[:ExValue]) then return item[:ExValue] end

    # convert attributes from MWB into Ensemble and use the
    attrs = {}
    # strip leading zeros from table name, MWB format.
    if (item[:Table]) then attrs[:codetable]= item[:Table].sub(/^0+/, '') end
    if (item[:Length]) then attrs[:max_length]= item[:Length] end
    if (item[:Name]) then attrs[:description] = item[:Name] end
    if (item[:Datatype]) then attrs[:datatype] = item[:Datatype] end

    # return genereated field
    # use primary field generator, as templates only work for custom schema.
    @fieldGenerators[PRIMARY].method(attrs[:datatype]).call(attrs, true)
  end

  # using MWB profiles build collection of message metadata, to use for building a message
  def build_metadata(useExVal)
    meta = {}
    segments = []
    # list of segments
    # In the event of Subgroups of Segments defined in the template, find them and allow
    # groups only once for simplicity.
   if( @xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('SegGroup')) then
      nodes = @xml.HL7v2xConformanceProfile.HL7v2xStaticDef.nodes

      nodes.each{|node|
        if (node.value == "Segment") then
          segments << node
        elsif (node.value == "SegGroup")then
          segments << node.locate('Segment')
        end
      }
     segments.flatten!
   else
    segments = @xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')
   end

    segments.each{|seg|

      fields = []
      seg.locate('Field').each_with_index { |f,idx |
        # if (@@USAGES.include?(f.Usage))
        if use?(f.Usage)
          f.attributes.merge!(:Pos => idx)
          fields << get_metadata(f,useExVal)
        end
      }

      meta[seg.attributes[:Name]] = fields
    }

    return meta
  end

  # parse template xml file into collection
  def get_metadata(partial, useExVal)

    element = partial.locate(COMPONENT)

    # first look for DataValues example if it's there use it and stop looking any farther.
    if(useExVal && (element.empty?) && !partial.locate(DATAVALUES).empty?)
        exVal = partial.locate(DATAVALUES).first.attributes
        partial.attributes.merge!(exVal)
        return partial.attributes
    end

    # continue looking for subcomponents
    element = (element.empty?) ? partial.locate(SUBCOMPONENT) : element
    if(!element.empty?)
        sub = []

        element.each_with_index { |el, idx|

          if (use?(el[:Usage])) # required or optional
            el.attributes.merge!(:Pos => idx)
            sub << get_metadata(el, useExVal)
          end

        }

        if(!sub.empty?)
          subElementName = (element.first.value.downcase).intern # subcomponent or component
          partial.attributes[subElementName] = sub
        end

    end

    return partial.attributes

  end

  # check for required field/compnent/subcomponent: R
  # if not toss a coin for optional (required or empty): RE (required or empty)
  return (USAGES_REQ.include?(usage)) ? true : (USAGES_OPT.include?(usage) && [true,false].sample)
  def use?(usage)
  end

end