require 'ox'
require 'yaml'
require_relative 'service/utils'

class ProfileParser
  include Utils

  #instance attributes
  attr_reader :base;
  alias_method :base?, :base;

  @@FILTER_ALL = {filter: '.*', group: 'All'}
  FILTER_ADM = {filter: 'ADT_A|QBP_Q2|RSP_K2[1-4]', group: 'Admissions'}
  FILTER_PH= {filter: 'OMP_|ORP_|RDE_|RRE_|RDS_|RRD_|RGV_|RRG_|RAS_|RRA_', group: 'Pharmacy'}


  # attr_accessor :std; :version; :event; :xml; :version_store;
  # @@HL7_VERSIONS = {'2.4'=>'2.4/2.4-schema.xml', 'vaz2.4'=>'vaz2.4/vaz2.4-schema.xml'}
  #class attribute
  # @@segment_patern = /\[([^\[\]]*)\]/
  @@segment_patern = /\[([^\[\]]*)\]|\{([^\[\]]*)\}/

  # Child class has a wrapper TODO: Refactor
  # def initialize(version=nil, event=nil)
  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    # set to false if it has not been set already
    # @base ||= false

    profile, path = nil
    # if(@version_store)
      profile = @version_store.find{|v| v[:std] == @std}[:profiles].find{|p| p[:doc] == @version }[:path]
      path = @version_store.detect{|v| v[:std] == @std}[:path]
    # else
    #   # path = self.class.get_schema_location
    #   # profile = File.path(path+ @@HL7_VERSIONS[@version])
    # end

    @xml = Ox.parse(IO.read(profile))

    # added = File.path(path+'added.xml')
    begin
      added = File.path(path+'/added/coded-tables.xml')
      @added = Ox.parse(IO.read(added))
    rescue => e
      puts e.message
    end

    # set flag if this is base or custom schema
    @base = (@xml.Export.Document.Category.attributes[:std] == '1')

  end

  # instance methods
  def self.get_schema_location
    properties_file = File.expand_path('../resources/properties.yml', __FILE__)
    yml = YAML.load_file properties_file
    path = yml['web.install.dir'] # set when run intall gem with argument, example: gem install 'c:/ez7Gen/ez7gen-web/config/resources/'
    path = File.join(path, 'config/schema/')
      # path = path<<'config/schema/'
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

    # Per Galina, code table values with special characters.
    # Ensemble validation fails.
    attributes.select!{|a| !has_special_ch?(a[:description])}

    return attributes
  end

  def lookup_code_table(tableName, path)
    tbl = path.Export.Document.Category.locate('CodeTable').select { |it| it.attributes[:name] == tableName }
    (!blank?(tbl)) ? tbl.first.locate('Enumerate').map { |it| it.attributes } : [Utils::DATA_LOOKUP_MIS]
  end

  def get_segment_structure(segment)
    segmentName = get_segment_name(segment)
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == segmentName }.first.locate('SegmentSubStructure').map{|it| it.attributes}
    #values.each {|it| puts it}
  end

  def lookup_message_types(map=nil)
    # match everything if no filter defined
    map ||= @@FILTER_ALL

    filter = map[:filter]
    messageTypeColl = @xml.Export.Document.Category.locate('MessageType').select{|it| it.attributes[:name] =~/#{filter}/}.map!{|it| it.attributes[:name]}
    messages = messageTypeColl.map{ |el|
      event = (el.split('_')).last
       {
          name: el,
          #chek if there is a match otherwise use the segment name
          code: ((e = @xml.Export.Document.Category.locate('MessageEvent').select{|it| it.attributes[:name] == event}); e!=[] )? (e.first().attributes[:description]): el,
          group: map[:group]
      }
    }
    return messages
  end

  # helper method to look up messages for specific groups of messages
  def lookup_message_groups (groups)
    messages = []
    groups.each{|group|
     messages += lookup_message_types(group)
    }
    return messages
  end

  end