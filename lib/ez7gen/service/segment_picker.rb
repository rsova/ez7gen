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
  def pick_segment_idx_to_build
    candidates = get_required_segment_idxs()
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

  # select optional segments and add them to required in correct order
  def pick_optional_segment_idxs()

    optSegmentIdxs = @profile.select{|it| !is_required?(it)}
    # optSegmentIdxs = segmentsToBuildArray.each_index.select{|i| segmentsToBuildArray[i] == nil}
    count = get_load_candidates_count(optSegmentIdxs.size())

    # get indexes of optional segments
    ids = optSegmentIdxs.sample(count)

    # add selected optional segments to required, maintain order
    ids.each{|id| @profile[@profile.index(id)]= @encodedSegments[id]}

  end
  #end refactoring

  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pick_segments()
    segmentCandidates = get_segments_to_build()
    return segmentCandidates - @@MSH_SEGMENTS
    # "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    #return [ 'EVN', 'PID','[~PD1~]', 'PV1','[~{~AL1~}~]', '[~{~DG1~}~]']
    #return ['~base:EVN','base:PID','[~base:PD1~]','~base:PV1','[~{~base:AL1~}~]','[~{~base:DG1~}~]','[~ZEL~]','[~ZEM~]','[~ZEN~]','[~ZMH~]']
  end

  # pick segments randomly, according to the load factor, exclude groups
  def get_segments_to_build()

      # place required segments according to their order in the segment
      get_required_segments()

      # place optional segments according to their order
      pick_optional_segments()

      # clean up profile, delete unselected optional segments
      @profile.delete_if{|it| (!is_required?(it))||(it==nil)}
  end

  # select optional segments and add them to required in correct order
  def pick_optional_segments()

      optSegmentIdxs = @profile.select{|it| !is_required?(it)}
      # optSegmentIdxs = segmentsToBuildArray.each_index.select{|i| segmentsToBuildArray[i] == nil}
      count = get_load_candidates_count(optSegmentIdxs.size())

      # get indexes of optional segments
      ids = optSegmentIdxs.sample(count)

      # add selected optional segments to required, maintain order
      ids.each{|id| @profile[@profile.index(id)]= @encodedSegments[id]}

  end

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

  # def handleRequiredSegments(segmentsToBuild)
  #   reqSegments = get_required_segments()
  # end

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
      seg = @encodedSegments[encoded]
      # Required segments left not encoded as strings, optional and groups encoded - indexes of encoded segments
      if(seg.instance_of?RepeatingGroup)
        check = true
      elsif(seg.instance_of?String)
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
        segment = @encodedSegments[encoded]
        #if segment happen to be a group, flatten it into string
        if(segment.kind_of?Array)
          segment = segment.flatten().to_s
        end
    else
      #segment was not encoded to an index, use it as is
      segment = encoded
    end

     (segment =~ /\~Z/)? true: false
  end
end