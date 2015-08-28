require 'rexml/document'
include REXML
require_relative 'service/utils'

class ProfileParser
  #instance attributes
  attr_accessor :version; :event; :xml;

  #class attribute
  @@segment_patern = /\[([^\[\]]*)\]/

  def initialize(version, event)
    @version = version;
    @event = event;
    puts @version
    puts @event
    @xml = Document.new(File.new('../lib/ez7gen/resources/base24.xml'))

  end

  def getSegments
    structrue = getMessageStructure()
    # puts structrue
    processSegments(structrue)
  end

  # find message structure by event type
  def getMessageStructure
    msg_type = @xml.elements["Export/Document/Category/MessageType[@name ='#{@event}']"].attributes["structure"]
    p msg_type
    structure = @xml.elements["Export/Document/Category/MessageStructure[@name ='#{msg_type}']"].attributes["definition"]
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
    values = @xml.elements.collect("Export/Document/Category/CodeTable[@name ='#{tableName}']/Enumerate"){|x| x.attributes}
  end

  def getSegmentStructure(segment)
    segmentName = Utils.getSegmentName(segment)
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    values.each {|it| puts it}
  end

end