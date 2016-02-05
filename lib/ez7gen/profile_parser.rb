require 'ox'
require 'yaml'
require_relative 'service/utils'

class ProfileParser
  include Utils

  #instance attributes
  # attr_accessor :version; :event; :xml; # :version_store; :store_cache;
  @@HL7_VERSIONS = {'2.4'=>'2.4/2.4-schema.xml', 'vaz2.4'=>'vaz2.4/vaz2.4-schema.xml'}
  #class attribute
  # @@segment_patern = /\[([^\[\]]*)\]/
  @@segment_patern = /\[([^\[\]]*)\]|\{([^\[\]]*)\}/

  # Child class has a wrapper TODO: Refactor
  # def initialize(version=nil, event=nil)
  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end

    # @version_store ||= @@HL7_VERSIONS
    # @version ||= version;
    # @event ||= event;

    # @std @version_store @store_cache - used with wrapper child class

    profile, path = nil
    if(@version_store)
      profile = @version_store.detect{|v| v[:std] = @std}[:profiles].detect{|p| p[:doc] = @version }[:path]
      path = @version_store.detect{|v| v[:std] = @std}[:path]
    else
      path = self.class.get_schema_location
      profile = File.path(path+ @@HL7_VERSIONS[@version])
    end

    @xml = Ox.parse(IO.read(profile))

    # added = File.path(path+'added.xml')
    begin
      added = File.path(path+'/added/coded-tables.xml')
      @added = Ox.parse(IO.read(added))
    rescue => e
      puts e.message
    end

  end

  # instance methods
  def self.get_schema_location
    properties_file = File.expand_path('../resources/properties.yml', __FILE__)
    yml = YAML.load_file properties_file
    path = yml['web.install.dir'] # set when run intall gem with argument, example: gem install 'c:/ez7Gen/ez7gen-web/config/resources/'
    path = path<<'config/schema/'
    # path = path<<'config/resources/'
  end

  def self.lookup_versions
    path = self.get_schema_location
    names = Dir.glob("#{path}*").select {|f| File.directory? f}
    versions = names.map{|it| { std: it.sub(path,''), path: it}}
    # for each version
    # look get list of .xml files, except added,own directory for added?
    versions.each{|version|
      profiles = []

      Dir.glob("#{version[:path]}/**").select {|file| !File.directory? file}.each{|path|
        xml = Ox.parse(IO.read(path))
        # for each schema collect metadata
        profile = xml.Export.Document.attributes
        profile[:doc] = profile.delete(:name) # resolve collision with same keys
        profile.merge!(xml.Export.Document.Category.attributes)
        profile[:path] = path
        profiles << profile
      }
      version[:profiles] = profiles
    }
  end

  # class methods
  def get_segments
    structrue = get_message_definition()
    # puts structrue
    process_segments(structrue)
  end

  # find message structure by event type
  def get_message_definition
    msg_type = get_message_structure(@event)
    p msg_type
    @xml.Export.Document.Category.locate('MessageStructure').select{|it| it.attributes[:name] == msg_type }.first.attributes[:definition]
  end

  def get_message_structure(event)
    msg_type = @xml.Export.Document.Category.locate('MessageType').select { |it| it.attributes[:name] == event }.first.attributes[:structure]
  end


  #get hash of attributes for codeTable values
  def get_code_table(tableName)
    #exclude 361,362 sending/receiving app and facility
    #if(tableName in ['72','88','132','264','269','471','9999']){
    #	println tableName
    #}

    #empty hash if no table name
    return [] if blank?(tableName)

    attributes = lookup_code_table(tableName, @xml)

    if(blank?(attributes))||(attributes.size == 1  && attributes[0][:value] =='...')
      attributes = lookup_code_table(tableName, @added)
    end

    return attributes
  end

  def lookup_code_table(tableName, path)
    tbl = path.Export.Document.Category.locate('CodeTable').select { |it| it.attributes[:name] == tableName }
    (!blank?(tbl)) ? tbl.first.locate('Enumerate').map { |it| it.attributes } : [{:position => '1', :value => '...', :description => 'No suggested values defined'}]
  end

  def get_segment_structure(segment)
    segmentName = get_segment_name(segment)
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == segmentName }.first.locate('SegmentSubStructure').map{|it| it.attributes}
    #values.each {|it| puts it}
  end

  def lookup_message_types(filter=nil)
    filter ||= '.*'# match everything if no filter defined

    messageTypeColl = @xml.Export.Document.Category.locate('MessageType').select{|it| it.attributes[:name] =~/#{filter}/}.map!{|it| it.attributes[:name]}
    map = messageTypeColl.map{ |el|
      event = (el.split('_')).last
       {
          name: el,
          #chek if there is a match otherwise use the segment name
          code: ((e = @xml.Export.Document.Category.locate('MessageEvent').select{|it| it.attributes[:name] == event}); e!=[] )? (e.first().attributes[:description]): el
      }
    }
    return map
  end


  # find all optional, repeating segemnts and segment groups
  # the required string left un-handled
  def process_segments(structure)
    idx = 0
    encodedSegments =[]

    # while(m = (structure.match(@@segment_patern).to_s))
    while(m = structure[@@segment_patern])
      structure.sub!(@@segment_patern,idx.to_s)
      encodedSegments << m
      idx +=1
    end

    # pre-process structure into collection of segments
    profile = structure.split('~').map!{|it| (is_number?(it))?it.to_i : it}

    # handle groups
    handle_groups(profile, encodedSegments)
  end

  # check if encoded segment is a group
  def is_group?(encoded)
     # group has an index of encoded optional element
     isGroupWithEncodedElements = (encoded =~ /\~\d+\~/)? true: false

     # group consists of all required elements {~MRG~PV1~}, so look ahead for that
     subGroups = encoded.split(/[~\{\[\}\]]/).delete_if{|it| blank?(it)}
     isGroupOfRequiredElements = (subGroups.size > 1)? true: false

     return (isGroupWithEncodedElements || isGroupOfRequiredElements), subGroups
    end

  # Groups need to be preprocessed
  # Group string replaced with array of individual segments
  def handle_groups(profile, encodedSegments)

    #find groups and decode the group elements and put them in array
    encodedSegments.map!{ |seg|
      groupFound, tokens = is_group?(seg)
      if(groupFound)
        #substitute encoded group elements with values
        tokens.map!{|it| is_number?(it)? encodedSegments[it.to_i]: it}.flatten
      else
        seg = seg
      end
    }
    return profile, encodedSegments
  end

end