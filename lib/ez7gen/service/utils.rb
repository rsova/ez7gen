class Utils
  def self.getSegmentName(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end

  def self.blank?(obj)
    return obj.nil? || obj.empty?
  end

end