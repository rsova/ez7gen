require_relative 'utils'

class SegmentPicker
  include Utils

  attr_accessor :encodedSegments
  attr_accessor :profile

  # private List segments
  # private String profile

  # load 50 percent of optional segments
  @@LOAD_FACTOR = 0.5
  @@MSH_SEGMENTS = ['MSH', "#{BASE_INDICATOR}MSH"]
  #@@MSH_SEGMENTS = ['MSH', "base:MSH"]

  # static final Random random = new Random()
  @@random = Random.new

  def initialize(profile, encodedSegments, loadFactor=nil)
    @profile = profile
    @encodedSegments = encodedSegments

    @loadFactor = loadFactor
    @loadFactor||=@@LOAD_FACTOR # set to default if not specified or set to nil
  end

  # def initialize(segmentsMap)
  #   @encodedSegments = segmentsMap[:segments]
  #   @profile = segmentsMap[:profile].split('~')
  #   @profile.map!{|it| (is_number?(it))?it.to_i : it}
  # end

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
  def is_required?(encoded)
    # Required segments left not encoded as strings, optional and groups encoded as numbers
    !is_number?(encoded)
  end


end