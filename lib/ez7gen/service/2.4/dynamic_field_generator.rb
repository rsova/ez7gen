require 'yaml'
require_relative '../../profile_parser'
require_relative '../base_field_generator'

class DynamicFieldGenerator < BaseFieldGenerator
  include Utils

  # constructor
  def initialize(pp)
    super pp
  end

  # base data types ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]

  def dynamic(name, map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    sub_types = []
    value = []

    @pp.xml.Export.Document.Category.locate('DataType').select{|it| it.attributes[:name] == name}.first.locate('DataSubType').each{ |it| sub_types << it.attributes}

    sub_types.each{ |sub_type|
      # check if field is required
     begin
      value << method(sub_type[:datatype]).call(sub_type,true)
     rescue NameError => e
       # puts e
       $log.error("#{self.class.to_s}:#{__method__.to_s}") { e.message }
       sub_values = dynamic(sub_type[:datatype], sub_type, true)

       # TODO :remove trailing empty fields
       # TODO: handle fields and subfields if it deeper then 3 levels in DR : "761&663^753&799"
       value << sub_values.gsub(@@HAT,@@SUB)
       puts sub_values
     end
    }

    return value.join(@@HAT)
  end

  #


end
