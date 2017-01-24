require_relative 'utils'
require_relative '../../ez7gen/structure_parser'

class SegmentPicker
  include Utils

  attr_accessor :encodedSegments
  attr_accessor :profile

  # load 50 percent of optional segments
  @@LOAD_FACTOR = 0.5
  @@MSH_SEGMENTS = ['MSH', "#{BASE_INDICATOR}MSH"]
  #@@MSH_SEGMENTS = ['MSH', "base:MSH"]

  @@random = Random.new

  def initialize(profile, encodedSegments, loadFactor=nil)
    @profile = profile
    @encodedSegments = encodedSegments
    #refactoring
    @candidates =[]

    @loadFactor = loadFactor
    @loadFactor||=@@LOAD_FACTOR # set to default if not specified or set to nil
  end

  #refactoring
  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pick_segments_to_build()
    idxs = pick_segment_idx_to_build
    segmentCandidates = build_segments_for_indexes(idxs)
    return segmentCandidates - @@MSH_SEGMENTS
  end

  # Turn indexes to segments
  def build_segments_for_indexes(idxs)
    idxs.map do |it|
      if(is_number?(@profile[it]))
          idx = @profile[it].to_i
          @encodedSegments[idx]
        else
          @profile[it]
      end
    end
  end

  def pick_segment_idx_to_build
    reqIdxs= get_required_segment_idxs()
    #profile indexes - reqired = optional?
    optIdxs = get_optional_segment_idxs(reqIdxs)
    (reqIdxs+optIdxs).sort.uniq
  end

  def get_optional_segment_idxs(regiredIdxs)
    # range of indexes
    allIdxs = (0...@profile.size).to_a
    optIdxs = allIdxs- regiredIdxs
    count = get_load_candidates_count(optIdxs.size())
    optIdxs.sample(count)
  end

  # get segments that will always be build, include z segments
  def get_required_segment_idxs()
    # profile already has all required segments identified
    rs = @profile.each_index.select{|it| is_required1?(@profile[it])}
    # promote z segments to required, and add them as required, keeping their index
    zs = @profile.each_index.select{|it| is_z1?(@profile[it])}
    # return indexes
    (rs+zs).sort.uniq
  end

  #end refactoring

  # get segments that will always be build, include z segments
  def get_required_segments()
    # profile already has all required segments identified
    # promote z segments to required, and add them as required, keeping their index
    zs = @encodedSegments.select{|it| is_z?(it)}

    #promote z to required, replace it's placeholder in profile with the value of the segment
    # adjust optional segments, clear the value, but do not delete to preserve the indexes
    zs.each{|it| idx = @encodedSegments.index(it); @profile[@profile.index(idx)] = it; @encodedSegments[idx] = nil}

    #reset encoded segments
    @encodedSegments.delete_if{|it| it == nil}

    # Make a copy of profile and set to nil all optional segments, indexes into encoded segments array
    # required = []
    # @profile.each{|it| required << Utils.num_to_nil(it)}
    #
    return @profile.select{|it| is_required?(it)}
  end

  # calculate number of segments based on load factor
  def get_load_candidates_count(total)
    (total*@loadFactor).ceil     #round it up
  end

  # check is segment is required
  def is_required1?(encoded)
    check = false
    #segment not encoded
    if(!is_number?(encoded))
      check = true
    else
      # look at encoded segment for the index
      seg = @encodedSegments[encoded.to_i]
      # Required segments left not encoded as strings, optional and groups encoded - indexes of encoded segments
      if(seg.instance_of?(RepeatingGroup))
        check = true
      elsif(seg.instance_of?(String))
        check = (seg[0] == '{' ) # signifies repeating segment
      end
    end

    return check
   end

  def is_required?(encoded)
  # Required segments left not encoded as strings, optional and groups encoded as numbers
    !is_number?(encoded)
  end


  def is_z?(segment)
    segment=~/\~Z/
  end

  #refactoring
  def is_z1?(encoded)
  segment = ''
    if(is_number?(encoded))
        # look at encoded segment for the index
        segment = @encodedSegments[encoded.to_i]
        #if segment happen to be a group, flatten it into string
        if(segment.kind_of?(Array))
          segment = segment.flatten().to_s
        end
    else
      #segment was not encoded to an index, use it as is
      segment = encoded
    end

     (segment =~ /\~Z/)? true: false
  end
end