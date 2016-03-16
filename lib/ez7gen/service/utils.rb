module Utils
  @@random = Random.new

  BASE_INDICATOR = 'base:'
  BASE = 'base'
  PRIMARY = 'primary'
  DATA_LOOKUP_MIS = {:position => '1', :value => '...', :description => 'No suggested values defined'}

  #special = "?<>',?[]}{=-)(*&^%$#`~{}"
  @@special = "?<>[]}{)(&^%$#`~{}" # subset to use for now
  @@regex = /[#{@@special.gsub(/./){|char| "\\#{char}"}}]/



  def get_segment_name(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end

  def blank?(obj)
    return obj.nil? || obj.empty? #|| obj.strip.empty?
  end

  # safely pick an index with collection
  def sample_index (len)
    # ... excludes the top of the range
    @@random.rand(0...len)
  end

  # check if string is a number
  def is_number?(str)
    true if Float(str) rescue false
  end

  def is_z?(str)
    str=~/\~Z/
  end

  # if name starts with base use base type otherwise primary
  # works for generators and parsers
  def get_type_by_name(name)
    (blank?(name)?nil:(name.include?(BASE_INDICATOR))? BASE: PRIMARY)
  end

  def get_name_without_base(name)
    (!blank?(name))?name.delete(BASE_INDICATOR):nil
  end

  # helper method to convert a string to nil if it's a number
  def num_to_nil(string)
      Integer(string || '')
      return nil
    rescue ArgumentError
      return string
  end

  # helper method to safely handle max length when schema len adn requirements contradict.
  # lesser wins
  def safe_len(maxLen, reqLen)
    #handle stings and garbage
    maxLen = (maxLen||reqLen).to_i
    [maxLen, reqLen].min
  end

  # check if string has special characters
  def has_special_ch?(str)
    (str =~ @@regex)?true:false
  end
end