class Utils
  def self.getSegmentName(segment)
    return segment.gsub(/~|\[|\]|\{|\}/,"")
  end
end