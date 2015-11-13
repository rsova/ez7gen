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
    return segmentCandidates - @@MSH_SEGMENTS
    # "MSH~EVN~PID~[~PD1~]~[~{~ROL~}~]~[~{~NK1~}~]~PV1~[~PV2~]~[~{~ROL~}~]~[~{~DB1~}~]~[~{~OBX~}~]~[~{~AL1~}~]~[~{~DG1~}~]~[~DRG~]~[~{~PR1~[~{~ROL~}~]~}~]~[~{~GT1~}~]~[~{~IN1~[~IN2~]~[~{~IN3~}~]~[~{~ROL~}~]~}~]~[~ACC~]~[~UB1~]~[~UB2~]~[~PDA~]"
    #return [ 'EVN', 'PID','[~PD1~]', 'PV1','[~{~AL1~}~]', '[~{~DG1~}~]']
    #return ['~base:EVN','base:PID','[~base:PD1~]','~base:PV1','[~{~base:AL1~}~]','[~{~base:DG1~}~]','[~ZEL~]','[~ZEM~]','[~ZEN~]','[~ZMH~]']
  end

  # check if encoded segment is a group
  def isGroup?(encoded)
  	return (encoded =~ /\~\d+\~/)? true : false
  end

  # protected handleSegment(int idx){
  # 	def n = segments.get(idx).getAt(0)
  # 	#TODO: Check if this is group and undo the group
  # 	return n
  # }

  # Groups need to be preprocessed
  def handleGroups(segments)
    #TODO: optional groups are deleted, revisit this
    segments.delete_if{|it| isGroup?(it)}
  end

  # pick segments randomly, according to the load factor, exclude groups
  def getSegmentsToBuild()

      # place required segments according to their order in the segment
      segmentsToBuild = getRequiredSegments()

      # place optional segments according to their order
      pickOptionalSegments(segmentsToBuild)

      # clean up nils from the array
      segmentsToBuild.compact()
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

    # Make a copy of profile and set to nil all optional segments,
    # which are numbers, indexes into encoded segments array
    required = []
    @profile.each{|it| required << Utils.numToNil(it)}

    # promote z segments to required, and add them as required, keeping their index
    zs = @encodedSegments.select{|it| isZ?(it)}
    zs.each{ |it| required[@encodedSegments.index(it)] = it}

    # adjust optional segments
    @encodedSegments = @encodedSegments - zs

    # pick from required and z segments
    #@profile.select{|it| isRequired?(it)}
    return required
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