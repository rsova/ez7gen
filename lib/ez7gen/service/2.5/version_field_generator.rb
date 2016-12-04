# require 'yaml'
require_relative '../../profile_parser'
require_relative '../base_field_generator'

class VersionFieldGenerator < BaseFieldGenerator
    include Utils
  # constructor
  def initialize(pp)
      super pp
  end

  # base data types ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]
  # def method_missing(method_name, *arguments, &block)
  #   if( method_name.to_s == method_name.upcase) # method name is all uppercase
  #     dynamic...
  #   else
  #     super
  #   end
  # end
  #
  # def respond_to_missing?(method_name, include_private = false)
  #   method_name.to_s.start_with?('user_') || super
  # end

  def generate_dt(name, map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    sub_types = []
    value = []

    begin
      # value << method(sub_type[:datatype]).call(sub_type,[true, false].sample)
      value << method(name).call(type,true)
    rescue NameError => e
      puts e
      # sub_values = dynamic(sub_type[:datatype], sub_type, [true, false].sample)
      values = generate_dt_from_schema(type)

      # TODO :remove trailing empty fields
      # TODO: handle fields and subfields if it deeper then 3 levels in DR : "761&663^753&799"
      value << values.gsub(@@HAT,@@SUB)
      puts values
    end
    return value

    # @pp.xml.Export.Document.Category.locate('DataType').select{|it| it.attributes[:name] == name}.first.locate('DataSubType').each{ |it| sub_types << it.attributes}
    #
    # for type in sub_types
    #   # check if field is required
    #   value << ((generate?(type)) ? generate_dt_from_schema(type) : '')
    # end
    #
    # return value.join(@@HAT)
  end

  # Method to generate field using schema description
  def generate_dt_from_schema(type)
    value = []
    begin
      # value << method(sub_type[:datatype]).call(sub_type,[true, false].sample)
      value << method(type[:datatype]).call(type,true)
    rescue NameError => e
      puts e
      # sub_values = dynamic(sub_type[:datatype], sub_type, [true, false].sample)
      values = generate_dt(type[:datatype], type, true)

      # TODO :remove trailing empty fields
      # TODO: handle fields and subfields if it deeper then 3 levels in DR : "761&663^753&799"
      value << values.gsub(@@HAT,@@SUB)
      puts values
    end
      return value
  end

end