# require 'yaml'
require_relative '../../profile_parser'
require_relative '../base_field_generator'

class FieldGenerator < BaseFieldGenerator
    include Utils

  # constructor
    def initialize(parser, helper_parser=nil)
      super(parser, helper_parser)
    end

  # base data types ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]

  def dt (name, attrs)
    dt = generate_dt(name, attrs)

    if(dt.is_a?(Array))
      dt = dt.map {|it| if(it.instance_of? (Array)) then it.join(@@SUB) else it end}.join(@@HAT)
      # dt.join(@@HAT)
    end
    return dt
  end

  def generate_dt(name, attrs, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(attrs, force))
    # p "generate_dt : #{name}"

    begin
      # value << method(sub_type[:datatype]).call(sub_type,[true, false].sample)
      dt = method(name).call(attrs, true)
      # p "generate_dt  basic dt: #{name}"

    rescue NameError => e
      # puts e
      # sub_values = dynamic(sub_type[:datatype], sub_type, [true, false].sample)
      dt = generate_dt_by_name(name)

      # TODO :remove trailing empty fields
      #while( blank?(value.last)) do value.pop end
      # value << value.join(@@SUB)

    end
    # puts dt
  # return (dt.is_a?(Array))?dt.join(@@SUB) :dt
  return dt

   end

  # Method to generate field using schema description
  def generate_dt_by_name(name)
    #p "generate_dt_by_name: #{name}, not a basic type"
    $log.info("#{self.class.to_s}:#{__method__.to_s}") {"generate_dt_by_name: #{name}, not a basic type"}

    dt = []
    types = []
    @pp.xml.Export.Document.Category.locate('DataType').select{|it| it.attributes[:name] == name}.first.locate('DataSubType').each{ |it| types << it.attributes}

    # types.slice!(0, types.length/2)
    # TODO: logic to build subtypes 1) look for Reqs, if not build # of sub-types, then build the rest
    for type in types
      # check if field is required
      dt << ((generate?(type)) ? generate_dt(type[:datatype], type) : '')
    end

    # remove trailing empty elements
    while( blank?(dt) and blank?(dt.last)) do
      dt.pop
    end

    return dt
  end

end