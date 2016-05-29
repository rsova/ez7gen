require 'yaml'
require_relative '../profile_parser'

class BaseFieldGenerator

  include Utils

  attr_accessor :yml,:pp
  # @@UP_TO_3_DGTS = 1000 # up to 3 digits
  @@REQ_LEN_3_DGTS = 3 #up to 3 digits
  @@RANGE_INDICATOR = '...'
  @@HAT = '^' # Component separator, aka hat
  @@SUB ='&' # Subcomponent separator
  # @@MONEY_FORMAT_INDICATORS = ['Money', 'Balance', 'Charge', 'Adjustment', 'Income', 'Amount', 'Payment','Cost']
  @@MONEY_FORMAT_REGEX = /\bMoney\b|\bBalance\b|\bCharge|\bAdjustment\b|\bIncome\b|\bAmount\b|\bPayment\b|\bCost\b|\bPercentage\b/
  @@INITIALS = ('A'..'Z').to_a
  @@GENERAL_TEXT = 'Notes'

  @@random = Random.new

  # constructor
  def initialize(pp)#/Users/romansova/RubymineProjects/ez7gen-staged/lib/ez7gen/resources/properties.yml
    @pp = pp
    # dirname =  File.join(File.dirname(File.expand_path(__FILE__)),'../../resources/properties.yml')
    propertiesFile = File.expand_path('../../resources/properties.yml', __FILE__)
    @yml = YAML.load_file propertiesFile
  end

  # base data types ["DT", "FT", "ID", "IS", "NM", "SI", "ST", "TM", "TN", "TX"]
  #Generates an HL7 DT (date) datatype.
  def DT(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    # #time of an event (TSComponentOne)
    to_datetime(map).strftime('%Y%m%d') #format('YYYYMMdd.SSS')Date.iso8601

  end

  # Formatted text data.
  # The FT field is of arbitrary length (up to 64k) and may contain formatting commands enclosed in escape characters.
  def FT(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    ID(map, true)
  end

  # Generate HL7 ID, usually using value from code table
  def ID(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    #value only
    #Case when max_len overrides requirements
    len = safe_len(map[:max_length], @@REQ_LEN_3_DGTS)
    (!blank?(map[:codetable]))? get_coded_value(map): generate_length_bound_id(len)
  end

  #Generates HL7 IS (namespace id) data type
  def IS(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    #TODO: same as ID?
    ID(map,true)
  end

  #Generates an HL7 NM (numeric) data type. A NM contains a single String value.
  def NM(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    val = 0
    case map[:description]
      when'Guarantor Household Size','Birth Order'
        val = generate_length_bound_id(1)
      when 'Guarantor Household Annual Income'
        val = '%.2f' % generate_length_bound_id(5)
      when @@MONEY_FORMAT_REGEX
        val = '%.2f' % ID(map,true)
      else
        val = ID(map,true) # general rule for a number
        if (map[:datatype] == 'CP' || map[:datatype] == 'MO') # money
          val = '%.2f' % val
        end
    end

    return val
  end

  #Generate HL7 SI (sequence ID) data type. A SI contains a single String value.
  def SI(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    #SI pt = (SI) map.fld
    #pt.setValue(generate_length_bound_id((map.max_length)?map.max_length.toInteger():1))
    len = (!blank?(map[:max_length]))?map[:max_length].to_i : 1
    generate_length_bound_id(len)
  end

  #Generate HL7 ST (string data) data type. A ST contains a single String value.
  def ST(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    # TODO add provider type ln 840 ROL
    case map[:description]
      when 'Guarantor SSN','Insured’s Social Security Number','Medicare health ins Card Number','Military ID Number', 'Contact Person Social Security Number'
        generate_length_bound_id(9)
      when 'Allergy Reaction Code'
        yml['codes.allergens'].keys.sample()
      when 'Strain'
        #PID.35 – PID.38 should be always blank, as they deal with animals, not humans.
      when 'AGENT ORANGE EXPOSURE LOCATION'
        #ZEL.29 should be 1 digit integer.
        generate_length_bound_id(1)
      when /family name/
        @yml['person.names.last'].sample
      when /given name/
        @yml['person.names.first'].sample
      when /suffix/
        @yml['person.suffix'].sample
      when /prefix/
        @yml['person.prefix'].sample
      else
        #Case when max_len overrides requirements
        len = safe_len(map[:max_length], @@REQ_LEN_3_DGTS)
        (!blank?(map[:codetable]))? get_coded_value(map): generate_length_bound_id(len)
    end

  end
  # An Elementary Data Type  Format: HH[MM[SS[.S[S[S[S]]]]]][+/-ZZZZ]
  # EX: 160140.761
  def TM(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    to_datetime(map).strftime('%H%M%S.%L')
  end

  #Generate an HL7 TN (telephone number) data type. A TN contains a single String value.
  def TN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    # TN tn = (TN) map.fld
    # tn.setValue(phones.getAt(Math.abs(random.nextInt()%phones.size())))
    @yml['address.phones'].sample # pick a phone
  end

  #Generate HL7 TX (text data) data type. A TX contains a single String value.
  def TX(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))
    # @@GENERAL_TEXT
    ID(map,true)
  end

  # end of base data types
  # implement missing method

  # data types using properties
  #Generates an HL7 FN (familiy name) data type.
  def FN(map, force=false)
    #check if the field is optional and randomly generate it of skip
    return '' if(!generate?(map, force))

    #surname (ST)
    @yml['person.names.last'].sample
    #own surname prefix (ST)
    #own surname (ST)
    #surname prefix from partner/spouse (ST)
    #surname from partner/spouse (ST)
  end


  #end of data types using properties

  # End of Data Types #

  # convention method to modify values of attirbutes
  def reset_map_attr(map, key, value)
    map[key.to_sym]=value
    return map
  end

# @return DateTime generated with consideration of description string for dates in the future
  def to_datetime(map)
    #for Time Stamp one way to figure out if event is in the future of in the past to look for key words in description
    isFutureEvent = !blank?(map[:description])&& map[:description].include?('End') #so 'Role End Date/Time'
    seed = 365 #seed bounds duration of time to a year
    days = @@random.rand(seed)

    if (map[:description]=='Date/Time Of Birth')
      isFutureEvent = false
      years = rand(30..50)
      days = days + 365*years # make a person 30 years old
    end

    (isFutureEvent) ? DateTime.now().next_day(days) : DateTime.now().prev_day(days)
  end

# If field are X,W,B (Not Supported, Withdrawn Fields or Backward Compatible)  returns false.
# Conditional (C) ?
# For Optional field (O) makes random choice
# R - Required returns true
# def autoGenerate?(map, force=false)
  def generate?(map, force=false)
    # return true
    return true if (force) #forced generation, ignore mappings

    #look up in the mapping
    case map[:required]
      when 'X', 'W', 'B' then
        false;
      when 'R' then
        true;
      when 'O' then
        [true, false].sample();
      else
        false;
    end
    # if(['X','W','B'].include?(map[:required]))then return false end
    # if(map[:required] =='R') then return true end
    # if(map[:required] == 'O') then return true end #random boolean
  end

# Returns randomly generated Id of required length, of single digit id
  def generate_length_bound_id(maxlen, str=@@random.rand(100000000).to_s)
    idx = maxlen
    if (maxlen > str.size)
      str = str.ljust(maxlen, '0')
      idx = str.size
    end
    #safe fail
    #this handles case when maxlen is less then 1
    idx = [0, idx-1].max
    return str[0..idx]
  end

  def handle_ranges(code)
    # if (code.include?(@@RANGE_INDICATOR))
    ends = code.delete(' ').split('...').map { |it| it }
    if (ends.empty?) # This is indication that codetable does not have any values
      code = ''
    else #Handle range values, build range and pick random value
      # range = ends.first..ends.last
      # code = range.to_a.sample

      # per Galina: Invalid value 'Q8' appears in segment 4:PD1, field 20, repetition 1, component 1, subcomponent 1,
      # but does not appear in code table 2.4:141.
      # I think you had to fix this one before to pull only the first and the last values from each row.
      code = ends.sample
    end
    return code
  end

  def handle_length(codes, maxlen)
    idx = codes.find_index { |it| it[:value].size <= maxlen }

    if (!idx)
      code, description = '', ''
    else
      # puts codes
      code = codes[idx][:value]
      description = codes[idx][:description]
    end
    return code, description
  end

# Handle range values specified by '...' sequence, including empty range
#TODO refactor candidate
  def apply_rules(codes, attributes)
    #safety check, no codes returns an empty map
    return {} if blank?(codes)

    #index of random element
    idx = sample_index(codes.size)
    code = codes[idx][:value]
    description = codes[idx][:description]

    if (code.include?(@@RANGE_INDICATOR))
      code = handle_ranges(code)
    end

    if (code.size > (maxlen = (attributes[:max_length]) ? attributes[:max_length].to_i : code.size))
      #remove all codes wich values violate
      #codes.select! {|it| it[:value].size <= maxlen }
      code, description = handle_length(codes, maxlen)
    end

    # got to have code, get an id, most basic - TODO: verify this.
    # if(Utils.blank?(code))
    #   code, description = ID({},true), ''
    # end
    # return code, description

    # puts code + ', ' + description
    return {:value => code, :description => description}
  end

  def get_code_table(attributes)
    codes = @pp.get_code_table(attributes[:codetable])
    # Case when we are looking for code values defined in base schema for types
    # which are in custom/primary schema. The SegmentGenerator checked for this condition
    # and dynamically added an instance value @bp  - the base parser to handle this issue
    if ((codes.first == Utils::DATA_LOOKUP_MIS) && defined?(@bp))
      codes = @bp.get_code_table(attributes[:codetable])
    end
    return codes
  end

# Values and Description from code table returned as a pair.
  def get_coded_map(attributes)
    codes = get_code_table(attributes)

    # puts codes
    #Apply rules to find a value and description
    #Returns map with code and description
    apply_rules(codes, attributes)
  end

# Value of coded table returned as as single value
  def get_coded_value(attributes)
    codes = get_code_table(attributes)

    # puts codes
    #Apply rules to find a value and description
    map = apply_rules(codes, attributes)
    #Return value only
    return map[:value]
  end

end
