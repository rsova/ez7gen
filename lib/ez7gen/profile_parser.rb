require 'ox'
require 'yaml'
require_relative 'service/utils'

class ProfileParser
  include Utils

  #instance attributes
  attr_reader :base,:xml;
  alias_method :base?, :base;

  # attr_reader :xml;

  @@FILTER_ALL = {filter: '.*', group: 'All'}
  FILTER_ADM =  {filter: 'ADT_A|QBP_Q2|RSP_K2[1-4]', group: 'Admissions'}
  FILTER_FM =   {filter: 'DFT_P03|DFT_P11|DFT_X03', group: 'Financial Management'}
  FILTER_GEN =  {filter: 'OSR_Q06|OSQ_Q06|ORG_O20|OMG_O19', group: 'General'}
  FILTER_LAB =  {filter: 'ORL_O22|OML_O21|QRY_R02|OUL_R21|ORU_R01', group: 'Laboratory'}
  FILTER_MSR =  {filter: 'MFN_M01|MFN_X01|MFN_Y01', group: 'Master Files'}
  FILTER_OBS =  {filter: 'OMS_O05', group: 'Order'}
  FILTER_PH =   {filter: 'OMP_|ORP_|RDE_|RRE_|RDS_|RRD_|RGV_|RRG_|RAS_|RRA_', group: 'Pharmacy'}

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

  def self.getExclusionFilterRule(std, version)
    path = self.get_schema_location
    rules_file = "#{path}#{std}/rules/#{version}.yml"

    if File.exists? (rules_file)
      yml = YAML.load_file rules_file
      all = []
      all += (yml['exclusion.errors'])?yml['exclusion.errors']:[]
      all += (yml['exclusion.blacklist'])?yml['exclusion.blacklist']:[]
    else
      []
    end

  end
  def self.getVersionUrlRule(std, version)
    path = self.get_schema_location
    rules_file = "#{path}#{std}/rules/#{version}.yml"

    if File.exists? (rules_file)
      yml = YAML.load_file rules_file
      (yml['version.url'])?yml['version.url']:nil
    else
      nil
    end

  end

  # find message structure by event type
  def get_message_definition
    msg_type = get_message_structure(@event)
    p msg_type
    definition = @xml.Export.Document.Category.locate('MessageStructure').select{|it| it.attributes[:name] == msg_type }.first.attributes[:definition]
    post_process(definition)
  end

  # helper method to handle corner cases
  def post_process(definition)

    if(@base && (@event == 'OSR_Q06'))
      # 1.If the OSQ_O06 query is about the status of the general messages OMG_O19 General Clinical Order and OML_O21 Lab Order, which only have the OBR segment, then the OSR_O06 should only have the OBR segment in its Order Detail Segment <   >.
      # 2.If the OSQ_O06 query is about the status of the Pharmacy order messages (OMP_O09, RDE_O11) that do not have OBR segment, but have RXO segment, then the OSR_O06 Order Detail Segment <     > should only contain RXO.
      # definition.sub!(/<(.*?)>/,['OBR','RXO'].sample())
      # puts definition
      definition = definition.sub!(/<(.*?)>/,['OBR','RXO'].sample())
      # puts definition
    elsif(@base && (@event == 'ORL_O22'))
      # work around for Ensemble issue where repeating group causes error in validation, remove repeating {} tag
      # MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~[~PID~{~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~}~]~]
      # 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~PID~{~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~}~]' #simplified
      # 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~PID~[~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~]~]' #changed
      definition = 'MSH~MSA~[~ERR~]~[~{~NTE~}~]~[~PID~[~[~SAC~[~{~OBX~}~]~]~[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]~]~]'
      # definition.sub('[~{~ORC~[~OBR~[~{~SAC~}~]~]~}~]', '[~ORC~[~OBR~[~{~SAC~}~]~]~]')
    else
      definition
    end
      return definition
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

    # Per Galina, code table values with special characters. Ensemble validation fails.
    # Filter out codes which have html encoded characters - Ensemble has problem handling it.
    # a bit of awkward logic - if either description or value has html encoded chars, remove the item
    attributes.select!{|a| (has_html_encoded_ch?(a[:description]) || has_html_encoded_ch?(a[:value]))?false:true }

    return attributes
  end

  def lookup_code_table(tableName, path)
    tbl = path.Export.Document.Category.locate('CodeTable').select { |it| it.attributes[:name] == tableName }
    (!blank?(tbl)) ? tbl.first.locate('Enumerate').map { |it| it.attributes } : [Utils::DATA_LOOKUP_MIS]
  end

  def get_segment_structure(segment)
    segmentName = get_segment_name(segment)
    puts segmentName
    # node = export.Document.Category.SegmentStructure.find{ it.@name == segmentName}
    # values = @xml.elements.collect("Export/Document/Category/SegmentStructure[@name ='#{segmentName}']/SegmentSubStructure"){|x| x.attributes}
    @xml.Export.Document.Category.locate('SegmentStructure').select{|it| it.attributes[:name] == segmentName }.first.locate('SegmentSubStructure').map{|it| it.attributes}
    #values.each {|it| puts it}
  end

  def lookup_message_types(map=nil, exclusion=nil)
    # match everything if no filter defined
    map ||= @@FILTER_ALL

    filter = map[:filter]
    messageTypeColl = @xml.Export.Document.Category.locate('MessageType').select{|it| it.attributes[:name] =~/#{filter}/}.map!{|it| it.attributes[:name]}
    if(!blank?(exclusion))
      messageTypeColl = messageTypeColl - exclusion
    end
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

  def lookup_events(params)

    #all events for version
    events = @xml.Export.Document.Category.locate('MessageType').map!{|it| it.attributes[:name]}

    #if there are exclusion rule, remove the exclusions
    if(!blank?(params[:exclusions]))
      events -= params[:exclusions]
    end

    templates = (!blank?(params[:templates_path]))? get_templates(params[:templates_path]) : []

    # go over the events and build attributes of the array
    events_with_attr = events.map{ |el|
      build_event_attributes(el, templates)
    }

    #events_with_attr
  end

  # build all the details for event type including template information
  def build_event_attributes(event, templates)
    # get event/message name ex: NO2 for ACK_NO2
    event_name = (event.split('_')).last

    attr = {}
    attr[:name] = event
    #chek if there is a match otherwise use the segment name
    attr[:code] = ((e = @xml.Export.Document.Category.locate('MessageEvent').select { |it| it.attributes[:name] == event_name }); e!=[]) ? (e.first().attributes[:description]) : event
    # group: map[:group]    # group is obsolete now

    # check if this event has matching template files
    # event_templates = templates.collect { |template| template =~/#{event}/ } unless blank?(templates)
    # attr[:templates] = templates unless blank?(event_templates)
    if (!blank?(templates))
      # try to match templates to an event by name
      event_templates = templates.select { |template| template =~/#{event}/i }
      # if found set event attribute with template names
      if(!blank?(event_templates))
         attr[:templates] = event_templates
      end
    end


   return attr
  end

  # # look up for message template files in a specified directory
  def get_templates(path)
    begin
      Dir.entries(path).select {|f| f =~/.xml/i}.sort
    # rescue => e
    rescue
      [] # handle case when dir is missing
    end
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