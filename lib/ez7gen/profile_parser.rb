require_relative 'service/utils'
require 'ox'
require 'yaml'

class ProfileParser
  #instance attributes
  attr_accessor :version; :event; :xml
  @@HL7_VERSIONS = {'2.4'=>'2.4/2.4-schema.xml', 'vaz2.4'=>'vaz2.4/vaz2.4-schema.xml'}
  #class attribute
  # @@segment_patern = /\[([^\[\]]*)\]/
  @@segment_patern = /\[([^\[\]]*)\]|\{([^\[\]]*)\}/

  def initialize(version, event=nil)
    @version = version;
    @event = event;

    propertiesFile = File.expand_path('../resources/properties.yml', __FILE__)
    yml = YAML.load_file propertiesFile
    path = yml['web.install.dir'] # set when run intall gem with argument, example: gem install 'c:/ez7Gen/ez7gen-web/config/resources/'

    path = path<<'config/resources/'
    profile = File.path(path+ @@HL7_VERSIONS[@version])
    @xml = Ox.parse(IO.read(profile))

    added = File.path(path+'added.xml')
    @added = Ox.parse(IO.read(added))
  end

  def getSegments
    structrue = getMessageDefinition()
    # puts structrue
    processSegments(structrue)
  end

  # find message structure by event type
  def getMessageDefinition
    msg_type = getMessageStructure(@event)
    p msg_type
    @xml.Export.Document.Category.locate('MessageStructure').select{|it| it.attributes[:name] == msg_type }.first.attributes[:definition]
  end

  def getMessageStructure(event)
    msg_type = @xml.Export.Document.Category.locate('MessageType').select { |it| it.attributes[:name] == event }.first.attributes[:structure]
  end


  #get hash of attributes for codeTable values
  def getCodeTable(tableName)
    #exclude 361,362 sending/receiving app and facility
    #if(tableName in ['72','88','132','264','269','471','9999']){
    #	println tableName
    #}

    #empty hash if no table name
    return [] if Utils.blank?(tableName)

    attributes = lookupCodeTable(tableName, @xml)

    if(Utils.blank?(attributes))||(attributes.size == 1  && attributes[0][:value] =='...')
      attributes = lookupCodeTable(tableName, @added)
    end

    return attributes
  end

  def lookupCodeTable(tableName, path)
    tbl = path.Export.Document.Category.locate('CodeTable').select { |it| it.attributes[:name] == tableName }
    (!Utils.blank?(tbl)) ? tbl.first.locate('Enumerate').map { |it| it.attributes } : [{:position => '1', :value => '...', :description => 'No suggested values defined'}]
  end

  def getSegmentStructure(segment)
    segmentName = Utils.getSegmentName(segment)
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == segmentName }.first.locate('SegmentSubStructure').map{|it| it.attributes}
    #values.each {|it| puts it}
  end

  def lookupMessageTypes(filter=nil)
    messageTypeColl = @xml.Export.Document.Category.locate('MessageType').map{|it| it.attributes[:name]}
    if(!Utils.blank?(filter))
      messageTypeColl = messageTypeColl.grep(/#{filter}/);
    end
    return messageTypeColl
  end


  # find all optional, repeating segemnts and segment groups
  # the required string left un-handled
  def processSegments(structure)
    idx = 0
    encodedSegments =[]
    # while(m = (structure.match(@@segment_patern).to_s))
    while(m = structure[@@segment_patern])
      structure.sub!(@@segment_patern,idx.to_s)
      encodedSegments << m
      idx +=1
    end

    # pre-process structure into collection of segments
    profile = structure.split('~').map!{|it| (Utils.isNumber?(it))?it.to_i : it}

    # handle groups
    handleGroups(profile, encodedSegments)
  end

  # check if encoded segment is a group
  def isGroup?(encoded)
    return (encoded =~ /\~\d+\~/)? true : false
  end

  # Groups need to be preprocessed
  # Group string replaced with array of individual segments
  def handleGroups(profile, encodedSegments)

    #find groups and decode the group elements and put them in array
    encodedSegments.map!{ |seg|
      if(isGroup?(seg))
        # break into a sequence of segments, no nils
        tokens = seg.split(/[~\{\[\}\]]/).delete_if{|it| Utils.blank?(it)}
        #substitute encoded group elements with values
        # tokens.map!{|it| Utils.isNumber?(it)? encodedSegments[it.to_i]:it}
        tokens.map!{|it| Utils.isNumber?(it)? encodedSegments[it.to_i]: it}.flatten
      else
        seg = seg
      end
    }

    return profile, encodedSegments
  end

end