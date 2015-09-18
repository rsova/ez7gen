require 'rexml/document'
# include REXML
require_relative 'service/utils'
require 'ox'

class ProfileParser
  #instance attributes
  attr_accessor :version; :event; :xml
  @@HL7_VERSIONS = {'2.4'=>'base24.xml', 'vaz2.4'=>'vaz2.4.xml'}
  #class attribute
  @@segment_patern = /\[([^\[\]]*)\]/

  def initialize(version, event)
    @version = version;
    @event = event;
    puts @version
    puts @event
    path = '../resources/'<< @@HL7_VERSIONS[@version]
    profile = File.expand_path(path, __FILE__)
    # profile = File.expand_path('../resources/base24.xml', __FILE__)
    @xml = Ox.parse(IO.read(profile))# load_file
  end

  def getSegments
    structrue = getMessageStructure()
    # puts structrue
    processSegments(structrue)
  end

  # find message structure by event type
  def getMessageStructure
    msg_type =  @xml.Export.Document.Category.locate('MessageType').select{|it| it.attributes[:name] == @event }.first.attributes[:structure]
    p msg_type
    @xml.Export.Document.Category.locate('MessageStructure').select{|it| it.attributes[:name] == msg_type }.first.attributes[:definition]
  end

  # find all optional, repeating segemnts and segment groups
  # the required string left un-handled
  def processSegments(structure)
    idx = 0
    segments =[]
    # while(m = (structure.match(@@segment_patern).to_s))
    while(m = structure[@@segment_patern])
      structure.sub!(@@segment_patern,idx.to_s)
      segments << m
      idx +=1
      # puts structure
      # puts m
      #if (idx > 25) then break(); end
    end
    return {profile: structure, segments: segments}
  end

  #get hash of attributes for codeTable values
  def getCodeTable(tableName)
    #exclude 361,362 sending/receiving app and facility
    #if(tableName in ['72','88','132','264','269','471','9999']){
    #	println tableName
    #}

    #empty hash if no table name
    return [] if Utils.blank?(tableName)
    # values = @xml.elements.collect("Export/Document/Category/CodeTable[@name ='#{tableName}']/Enumerate"){|x| x.attributes}
    n = @xml.Export.Document.Category.locate('CodeTable').select{|it| it.attributes[:name] == tableName }.first.locate('Enumerate').map{|it| it.attributes}

  end

  def getSegmentStructure(segment)
    segmentName = Utils.getSegmentName(segment)
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == segmentName }.first.locate('SegmentSubStructure').map{|it| it.attributes}
    #values.each {|it| puts it}
  end

end