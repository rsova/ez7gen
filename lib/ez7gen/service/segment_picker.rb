class SegmentPicker
  attr_accessor :segments
  attr_accessor :profile

  # private List segments
  # private String profile

  # load 50 percent of optional segments
  @@LOAD_FACTOR = 0.5
  # static final Random random = new Random()
  @@random = Random.new

  def initialize(segmentsMap)
    @segments = segmentsMap['segments']
    @profile = segmentsMap['profile']
  end

  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pickSegments()
    segmentCandidates = getSegmentsToBuild()
    return segmentCandidates - ['MSH']
    #return [ 'EVN', 'PID', 'PV1', '[~PD1~]', '[~{~AL1~}~]', '[~{~DG1~}~]']
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
  def handleGroups()
    #TODO: optional groups are deleted, revisit this
    @segments.delete_if{|it| isGroup?(it)}
  end

  # pick segments randomly, according to the load factor, exclude groups
  def getSegmentsToBuild()

      toBuild = []



      # @segments = handleGroups()

      total = @segments.size
      max_count = getLoadCandidatesCount(total)

      #get random array of segments
      @segments.sample(max_count)
  end


  # calculate number of segments based on load factor
  def getLoadCandidatesCount(total)
    (total*@@LOAD_FACTOR).ceil     #round it up
  end


end