class Utils
  @@random = Random.new

  @@BASE_INDICATOR = 'base:'
  @@BASE = 'base'
  @@PRIMARY = 'primary'

  # expose the class variables to the outside
  #TODO: Refactor
  def self.BASE_INDICATOR
    @@BASE_INDICATOR
  end

  def self.BASE
    @@BASE
  end

  def self.PRIMARY
    @@PRIMARY
  end

  def self.BASE_INDICATOR
    @@BASE_INDICATOR
  end

  def self.getSegmentName(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end

  def self.blank?(obj)
    return obj.nil? || obj.empty? #|| obj.strip.empty?
  end

  # safely pick an index with collection
  def self.sampleIdx (len)
    # ... excludes the top of the range
    @@random.rand(0...len)
  end

  # check if string is a number
  def self.isNumber?(str)
    true if Float(str) rescue false
  end

  def self.isZ?(str)
    str=~/\~Z/
  end

  # if name starts with base use base type otherwise primary
  # works for generators and parsers
  def self.getTypeByName(name)
    (name.include?(@@BASE_INDICATOR))?@@BASE:@@PRIMARY
  end

  def self.noBaseName(name)
    (!Utils.blank?(name))?name.delete(Utils.BASE_INDICATOR):nil
  end

end