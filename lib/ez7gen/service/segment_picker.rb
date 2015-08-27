class SegmentPicker
  attr_accessor :segments; :profile;

  # private List segments
  # private String profile

  # load 50 percent of optional segments
  # public double loadFactor = 0.5
  # static final Random random = new Random()


  # public SmartSegmentPickerService( String profile, List segments) {
  # 	this.segments = segments;
  # 	this.profile = profile;
  # }

  # public SmartSegmentPickerService(Map segmentsMap) {
  # 	init(segmentsMap);
  # }

  def initialize(segmentsMap)
    @segments = segmentsMap['segments']
    @profile = segmentsMap['profile']
  end


  # Get list of segments for test message generation.
  # MSH is populated with quick generation, skip it here.
  def pickSegments
    # List nonReqSegments = getSegmentCandidates()
    # List segments = getSegmentsToBuild(nonReqSegments);
    # return segments - ['MSH']
    return [ 'EVN', 'PID', 'PV1', '[~PD1~]', '[~{~AL1~}~]', '[~{~DG1~}~]']
  end

  # public List getSegmentsToBuild(){
  # List pList = profile.split("~")

  # List nonRequitedSegments = getSegmentCandidates()
  # List segmentsToKeep = []
  # for(String seg in pList){

  # 	if(seg.isNumber()) {
  # 		Integer segNbmr = seg.toInteger()
  # 		if(nonRequitedSegments.contains(segNbmr)){
  # 			def n = handleSegment(segNbmr)
  # 			segmentsToKeep.add(n)
  # 		}

  # 	}else{ segmentsToKeep.add(seg) }
  # }
  # return segmentsToKeep
  # }

  # public List getSegmentsToBuild(List pickedSegments){
  # List tokens  = profile.split("~")
  # List segmentsToKeep = []

  # for(String token in tokens){

  # 	//token can be encoded as number
  # 	if(token.isNumber()){
  # 		Integer tokenIdx = token.toInteger()
  # 		if(pickedSegments.contains(tokenIdx)){
  # 			//get string that was encoded
  # 			String sequence = segments.get(tokenIdx).get(0)
  # 			//token can be a group of symbols
  # 			if(isGroup(sequence)){
  # 				//TODO: Just skip group processing for now
  # 				println 'group : ' + sequence
  # 			}else{
  # 				segmentsToKeep.add(sequence)
  # 			}
  # 		}
  # 	}else{ // non encoded token is a keeper
  # 		segmentsToKeep.add(token)
  # 	}
  # }
  # return segmentsToKeep
  # }

  # //Check if encoded segment is a group
  # protected boolean isGroup(String encoded){
  # 	Matcher matcher = encoded =~ /\~\d+\~/
  # 	return matcher.find()
  # }

  # protected handleSegment(int idx){
  # 	def n = segments.get(idx).getAt(0)
  # 	//TODO: Check if this is group and undo the group
  # 	return n
  # }

  # protected List getSegmentCandidates(){
  # 	int max = getLoadCandidatesCount(segments.size())
  # 	Set randoms = []
  # 	while(randoms.size() < max){
  # 		randoms.add(random.nextInt(segments.size()).toInteger())
  # 	}
  # 	return randoms.sort() as List
  # }

  # protected int getLoadCandidatesCount(int total) {
  # 	//round it up
  # 	return Math.ceil(total*loadFactor).toInteger()
  # }


  # }

end