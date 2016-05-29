require 'yaml'
require_relative '../../profile_parser'
require_relative '../base_field_generator'

class DynamicFieldGenerator < BaseFieldGenerator
  include Utils

  # attr_accessor :yml,:pp
  # # @@UP_TO_3_DGTS = 1000 # up to 3 digits
  # @@REQ_LEN_3_DGTS = 3 #up to 3 digits
  # @@RANGE_INDICATOR = '...'
  # @@HAT = '^' # Component separator, aka hat
  # @@SUB ='&' # Subcomponent separator
  # # @@MONEY_FORMAT_INDICATORS = ['Money', 'Balance', 'Charge', 'Adjustment', 'Income', 'Amount', 'Payment','Cost']
  # @@MONEY_FORMAT_REGEX = /\bMoney\b|\bBalance\b|\bCharge|\bAdjustment\b|\bIncome\b|\bAmount\b|\bPayment\b|\bCost\b|\bPercentage\b/
  # @@INITIALS = ('A'..'Z').to_a
  # @@GENERAL_TEXT = 'Notes'
  #
  # @@random = Random.new

  # constructor
  def initialize(pp)#/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/properties.yml
    # @pp = pp
    # # dirname =  File.join(File.dirname(File.expand_path(__FILE__)),'../../resources/properties.yml')
    # propertiesFile = File.expand_path('../../resources/properties.yml', __FILE__)
    # @yml = YAML.load_file propertiesFile
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

  def dynamic(name, map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    sub_types = []
    value = []

    @pp.xml.Export.Document.Category.locate('DataType').select{|it| it.attributes[:name] == name}.first.locate('DataSubType').each{ |it| sub_types << it.attributes}

    sub_types.each{ |sub_type|
     begin
      # value << method(sub_type[:datatype]).call(sub_type,[true, false].sample)
      value << method(sub_type[:datatype]).call(sub_type,true)
     rescue NameError => e
       puts e
       # sub_values = dynamic(sub_type[:datatype], sub_type, [true, false].sample)
       sub_values = dynamic(sub_type[:datatype], sub_type, true)

       # TODO :remove trailing empty fields
       # TODO: handle fields and subfields if it deeper then 3 levels in DR : "761&663^753&799"
       value << sub_values.gsub(@@HAT,@@SUB)
       puts sub_values
     end
    }

    return value.join(@@HAT)
  end


end
