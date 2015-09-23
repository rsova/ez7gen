require_relative 'utils'

class SegmentPicker
  attr_accessor :encodedSegments
  attr_accessor :profile

  # private List segments
  # private String profile

  # load 50 percent of optional segments
  @@LOAD_FACTOR = 0.5
   @@MSH_SEGMENTS = ['MSH', "#{Utils.BASE_INDICATOR}MSH"]
  #@@MSH_SEGMENTS = ['MSH', "base:MSH"]

  # static final Random random = new Random()
  @@random = Random.new

  def initialize(segmentsMap)
    @encodedSegments = segmentsMap[:segments]
    @profile = segmentsMap[:profile].split('~')
  end

  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pickSegments()
    segmentCandidates = getSegmentsToBuild()
     # return segmentCandidates - @@MSH_SEGMENTS
    return [ 'EVN', 'PID', 'PV1', '[~PD1~]', '[~{~AL1~}~]', '[~{~DG1~}~]']
  end

  # check if encoded segment is a group
  def isGroup?(encoded)
  	return (encoded =~ /\~\d+\~/)? true : false
  end

  # protected handleSegment(int idx){
  # 	def n = segments.get(idx).getAt(0)
  # 	//TODO: Check if this is group and undo the group
  # 	return n
  # }

  # Groups need to be preprocessed
  def handleGroups(segments)
    #TODO: optional groups are deleted, revisit this
    segments.delete_if{|it| isGroup?(it)}
  end

  # pick segments randomly, according to the load factor, exclude groups
  def getSegmentsToBuild()
      keepers = []

      # place required segments according to their order in the segment
      reqSegments = getRequiredSegments()
      reqSegments.each{|it| keepers[@profile.index(it)] = it}
      #@profile.each{|it| keepers[reqSegments.index(it)] = it}

      # place optional segments according to their order in segment
      keepers = pickOptionalSegments(keepers)
      keepers.compact()
  end


  def pickOptionalSegments(segmentsToBuildArray)

      optSegmentIdxs = @profile.select{|it| !isRequired?(it)}
      count = getLoadCandidatesCount(optSegmentIdxs.size())

      # get indexes of optional segments
      ids = optSegmentIdxs.sample(count)
      # p ids
      ids.each{|it| segmentsToBuildArray[@profile.index(it)] = @encodedSegments[it.to_i]}
      handleGroups(segmentsToBuildArray)
  end

  # get segments that will always be build, include z segments
  def getRequiredSegments()
    # promote z segments to required
    zs = @encodedSegments.select{|it| isZ?(it)}
    zs.each{ |it| @profile[ @encodedSegments.index(it)] = it}

    # adjust optional segments
    @encodedSegments = @encodedSegments - zs

    # pick from required and z segments
    @profile.select{|it| isRequired?(it)}
  end

  # def handleRequiredSegments(keepers)
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