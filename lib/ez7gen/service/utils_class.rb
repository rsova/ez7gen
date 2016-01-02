class Utils_Class
  @@random = Random.new

  BASE_INDICATOR = 'base:'
  BASE = 'base'
  PRIMARY = 'primary'

  # expose the class variables to the outside
  #TODO: Refactor
  # def self.BASE_INDICATOR
  #   @@BASE_INDICATOR
  # end

  # def self.BASE
  #   @@BASE
  # end
  #
  # def self.PRIMARY
  #   @@PRIMARY
  # end
  #
  # def self.BASE_INDICATOR
  #   @@BASE_INDICATOR
  # end

  def self.get_segment_name(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end

  def self.blank?(obj)
    return obj.nil? || obj.empty? #|| obj.strip.empty?
  end

  # safely pick an index with collection
  def self.sample_index (len)
    # ... excludes the top of the range
    @@random.rand(0...len)
  end

  # check if string is a number
  def self.is_number?(str)
    true if Float(str) rescue false
  end

  def self.is_z?(str)
    str=~/\~Z/
  end

  # if name starts with base use base type otherwise primary
  # works for generators and parsers
  def self.get_type_by_name(name)
    (name.include?(BASE_INDICATOR))? BASE: PRIMARY
  end

  def self.get_name_without_base(name)
    (!Utils_Class.blank?(name))?name.delete(BASE_INDICATOR):nil
  end

  # helper method to convert a string to nil if it's a number
  def self.num_to_nil(string)
      Integer(string || '')
      return nil
    rescue ArgumentError
      return string
  end

  # helper method to safely handle max length when schema len adn requirements contradict.
  # lesser wins
  def self.safe_len(maxLen, reqLen)
    #handle stings and garbage
    maxLen = (maxLen||reqLen).to_i
    [maxLen, reqLen].min
  end
end