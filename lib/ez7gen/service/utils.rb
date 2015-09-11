class Utils
  @@random = Random.new

  def self.getSegmentName(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end

  def self.blank?(obj)
    return obj.nil? || obj.empty?
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

end