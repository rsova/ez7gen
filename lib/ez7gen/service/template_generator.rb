require_relative '2.4/dynamic_field_generator'
require_relative 'utils'

class TemplateGenerator
  include Utils

  @@USAGES = ['R','RE']

  def initialize(tempalte_path, pp)

    # parse template  TODO: refactor if not needed on class level move to 'build_template_metadata'
    text = File.path(tempalte_path)
    @xml = Ox.parse(IO.read(text))

    #If there are multiple profile parsers, instantiate a generators for each
    @fieldGenerators = {}
    pp.each{|profileName, profiler| @fieldGenerators[profileName] = DynamicFieldGenerator.new(profiler)}

    # for the custom messages, primary field generator has to look up base coded table values
    # add the parser on the fly to the field generator
    if(!@fieldGenerators[PRIMARY].pp.base?)
      baseParser = @fieldGenerators[BASE].pp
      @fieldGenerators[PRIMARY].instance_variable_set('@bp', baseParser)
    end

   end

  # build hl7 message using template as guideline
  # def generate(message, template, parsers, isGroup=false)
  def generate(message, template, isGroup=false)

    segments = template.keys
    # fields = []

    segments.each{|segment|

      f = template[segment]

      partials = break_to_partial(f)

      message << generate_segment(segment, partials)
    }

    return message
    # @fldGenerator.method(dt).call(attrs, true)
  end

  # generate a segment using Ensemble schema
  def generate_segment(segmentName, attributes, idx=nil)
    # elements = generate_segment_elements(segmentName, attributes)
    attributes.unshift(get_name_without_base(segmentName))
    # elements = generate_segment_elements(segmentName, attributes)
    # overrite ids for sequential repeating segments
    # elements[@@SET_ID_PIECE] = handle_set_id(segmentName, attributes, idx) || elements[@@SET_ID_PIECE]

    #generate segment using elements
    HL7::Message::Segment::Default.new(attributes)
  end
  # def add_field()
  #   # f = template[s]
  #   #
  #   # dt_partials = []
  #   #
  #   # dt_partials << break_to_partial(f)
  #   #
  #   type = get_type_by_name(attributes[:datatype])
  #   fieldGenerator= @fieldGenerators[type].
  #   dt = get_name_without_base(attributes[:datatype])
  #
  #
  #   # dt = attributes[:datatype]
  #   # puts Utils.blank?(dt)?'~~~~~~~~~> data type is missing': dt
  #   if(['CK'].include?(dt))
  #     return nil
  #   else
  #     fld = blank?(dt)?nil :fieldGenerator.method(dt).call(attributes)
  #   end
  #
  # end


  # parse template xml file into collection
  def build_template_metadata(usages=@@USAGES)
    # list of segments
    segs = @xml.HL7v2xConformanceProfile.HL7v2xStaticDef.locate('Segment')

    map = {}
    for seg in segs

      puts seg.attributes[:Name]
      meta = []
      # list of fields
      seg.locate('Field').each_with_index { |fld, fld_idx|
        if (usages.include?(fld.Usage)) #Usage="R"
          fld.attributes.merge!(:Pos => fld_idx)

          cmps = []
          fld.locate('Component').each_with_index { |cmp, cmp_idx|

            if (usages.include?(cmp.Usage))

              cmp.attributes.merge!(:Pos => cmp_idx)

              sub_comps = []
              cmp.locate('SubComponent').each_with_index { |sub, sub_idx|
                if (usages.include?(sub.Usage))
                  sub_comps << sub.attributes.merge(:Pos => sub_idx)
                end
              }# end locate SubComponent

              if (!sub_comps.empty?) then
                cmp.attributes.merge!(:subComponents => sub_comps)
              end
              if (cmp.attributes) then
                cmps << cmp.attributes
              end

            end
          }# end locate Component

          if (!cmps.empty?) then
            fld.attributes.merge!(:components => cmps)
          end

          meta << fld.attributes
        end

      }# end locate Field

      map[seg.attributes[:Name]] = meta
    end

    return map
  end

  # woring with template hash using it to brake field metadata to components and then to subcomponents
  def break_to_partial(item)
    partials = []

    if(item.kind_of? Array)

      item.each{|i|
        coll = i[:subComponents] || i
        partials[i[:Pos].to_i] = break_to_partial(coll).join((i[:subComponents])?'&':'^')
      }

    else

      coll = item[:components] || item[:subComponents]
      if(coll)
        partials << break_to_partial(coll)
      else
        partials << convert_attributes(item)
      end
    end

    return partials

  end

  # convert
  def convert_attributes(item)
    attrs = {}

    if (item[:Length]) then attrs[:max_length]= item[:Length] end

    if (item[:Table]) then attrs[:codetable]= item[:Table].sub(/^0+/, '') end

    if (item[:Name]) then attrs[:description] = item[:Name] end

    if (item[:Datatype]) then attrs[:datatype] = item[:Datatype] end

    # return attrs
    #
     # @fldGenerator[0].method(dt).call(attrs, true)#TODO: fix this
    @fieldGenerators[PRIMARY].method(attrs[:datatype]).call(attrs, true)#TODO: fix this
  end


  # def find_field_exValue(fld, idx)
  #
  #   if (!fld.locate('DataValues').empty?)
  #     {idx => fld.DataValues.attributes[:ExValue]  }
  #     # {fld.attributes[:ItemNo] => fld.DataValues.attributes[:ExValue]  }
  #   elsif (!fld.locate('Component/DataValues').empty?)
  #     puts fld
  #     {idx => fld.Component.DataValues.attributes[:ExValue]}
  #     # {fld.attributes[:ItemNo] => fld.Component.DataValues.attributes[:ExValue]}
  #   elsif ()
  #   end
  #
  # end

end