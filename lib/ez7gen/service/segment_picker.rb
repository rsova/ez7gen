require_relative 'utils'

class SegmentPicker
  attr_accessor :encodedSegments
  attr_accessor :profile

  # private List segments
  # private String profile

  # load 50 percent of optional segments
  # @@LOAD_FACTOR = 0.5
  @@LOAD_FACTOR = 1
   @@MSH_SEGMENTS = ['MSH', "#{Utils.BASE_INDICATOR}MSH"]
  #@@MSH_SEGMENTS = ['MSH', "base:MSH"]

  # static final Random random = new Random()
  @@random = Random.new

  def initialize(profile, encodedSegments)
    @profile = profile
    @encodedSegments = encodedSegments
  end

  # def initialize(segmentsMap)
  #   @encodedSegments = segmentsMap[:segments]
  #   @profile = segmentsMap[:profile].split('~')
  #   @profile.map!{|it| (Utils.isNumber?(it))?it.to_i : it}
  # end

  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pickSegments()
    segmentCandidates = getSegmentsToBuild()
    return segmentCandidates - @@MSH_SEGMENTS
    # "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    #return [ 'EVN', 'PID','[~PD1~]', 'PV1','[~{~AL1~}~]', '[~{~DG1~}~]']
    #return ['~base:EVN','base:PID','[~base:PD1~]','~base:PV1','[~{~base:AL1~}~]','[~{~base:DG1~}~]','[~ZEL~]','[~ZEM~]','[~ZEN~]','[~ZMH~]']
  end

  # # check if encoded segment is a group
  # def isGroup?(encoded)
  # 	return (encoded =~ /\~\d+\~/)? true : false
  # end
  #
  # # Groups need to be preprocessed
  # def handleGroups(segments=@profile)
  #   #TODO: optional groups are deleted, revisit this
  #   # segments.delete_if{|it| isGroup?(it)}
  #
  #   segments.map!{ |seg|
  #
  #     if(isGroup?(seg))
  #       # break into a sequence of segments, no nils
  #       tokens = seg.split(/[~\{\[\}\]]/).delete_if{|it| Utils.blank?(it)}
  #       #substitute encoded group elements with values
  #       tokens.map!{|it| Utils.isNumber?(it)? @encodedSegments[it.to_i]:it}
  #     else
  #       seg = seg
  #     end
  #   }
  #   # return segments
  # end

  # pick segments randomly, according to the load factor, exclude groups
  def getSegmentsToBuild()

      # place required segments according to their order in the segment
      getRequiredSegments()

      # place optional segments according to their order
      pickOptionalSegments()

      # clean up profile, delete unselected optional segments
      @profile.delete_if{|it| !isRequired?(it)}
  end

  # select optional segments and add them to required in correct order
  def pickOptionalSegments()

      optSegmentIdxs = @profile.select{|it| !isRequired?(it)}
      # optSegmentIdxs = segmentsToBuildArray.each_index.select{|i| segmentsToBuildArray[i] == nil}
      count = getLoadCandidatesCount(optSegmentIdxs.size())

      # get indexes of optional segments
      ids = optSegmentIdxs.sample(count)

      # add selected optional segments to required, contain order
      ids.each{|id| @profile[@profile.index(id)]= @encodedSegments[id]}

      # groups need to be expended if any selected
      # handleGroups()
  end

  # get segments that will always be build, include z segments
  def getRequiredSegments()
    # profile already has all required segments identified
    # promote z segments to required, and add them as required, keeping their index
    zs = @encodedSegments.select{|it| isZ?(it)}

    #promote z to required, replace it's placeholder in profile with the value of the segment
    # adjust optional segments, clear the value, but do not delete to preserve the indexes
    zs.each{|it| idx = @encodedSegments.index(it); @profile[@profile.index(idx)] = it; @encodedSegments[idx] = nil}

    #reset encoded segments
    @encodedSegments.delete_if{|it| it == nil}

    # Make a copy of profile and set to nil all optional segments, indexes into encoded segments array
    # required = []
    # @profile.each{|it| required << Utils.numToNil(it)}
    #
    return @profile.select{|it| isRequired?(it)}
  end

  # def handleRequiredSegments(segmentsToBuild)
  #   reqSegments = getRequiredSegments()
  # end

  # calculate number of segments based on load factor
  def getLoadCandidatesCount(total)
    (total*@@LOAD_FACTOR).ceil     #round it up
  end

  # check is segment is required
  def isRequired?(encoded)
    # Required segments left not encoded as strings, optional and groups encoded as numbers
    !Utils.isNumber?(encoded)
  end

  # check if it's a z segment
  def isZ?(seg)
    Utils.isZ?(seg)
  end
end