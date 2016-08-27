# require 'sinatra'
require 'sinatra/base'

require 'json'
require 'rest_client'
require 'diskcached'
require 'ez7gen'
require_relative '../lib/ez7gen/message_factory' # local testing
require_relative '../lib/ez7gen/profile_parser' # local testing
require_relative '../lib/ez7gen/msg_error_handler' # local testing

class MyApp < Sinatra::Application

#configure do
#   set :port, 9494
#   set :show_exceptions, :after_handler
#   disable :raise_errors
#end

@@URLS={'2.4'=>'localhost:9980/','VAZ2.4'=>'localhost:9981/'}
# admisson messages match pattern
@@FILTERS = [ProfileParser::FILTER_ADM, ProfileParser::FILTER_FM, ProfileParser::FILTER_GEN,  ProfileParser::FILTER_LAB, ProfileParser::FILTER_MSR, ProfileParser::FILTER_OBS, ProfileParser::FILTER_PH]

  # configure do
  #   $diskcache = Diskcached.new(File.join(settings.root, 'cache'))
  #   $diskcache.flush # ensure caches are empty on startup
  #   #cahe version store
  #   # MyApp.class.cache_lookup('version_store')
  #   puts 'in configure'
  # end

  #
  # before do
  #     @cache_key = cache_sha(request.path_info)
  # end

  get '/' do
    # content_type :json
    # redirect 'js/app.js'
    redirect 'views/index.html'
  end

  get '/version/' do
    content_type :json
    { version: Ez7gen::VERSION}.to_json
  end



 get '/pulse' do
    # vs = cache_lookup('version_store')
 end

  post '/generate/' do
    begin
      # no additional configuration needed for angularjs,
      params = JSON.parse(request.env["rack.input"].read)
      puts  params

      std = params['std']
      event =  params['event']['name']
      version =  params['version']['name']
      puts  "std: #{std}, event: #{event}, version: #{version}"
      useExVal = params['useExVal']
      useTemplate = params['useTemplate']

      vs = ProfileParser.lookup_versions()
      @resp = MessageFactory.new({std: std, version: version, event:event, version_store: vs, use_template: useTemplate}).generate(useExVal) #msg.replace('\r','\n' )

    rescue => e
      # puts 'inside rescue'
      puts 'Error: processing generate/' << e.inspect
      @resp ='Oops, somenthing went wrong...'
      #  raise e
      # ensure
    end
    #send response
    {message: @resp}.to_json

  end

  post '/validate/' do
    begin
      params = JSON.parse(request.env["rack.input"].read)
      puts params
      version =  params['version']['code']
      puts version
      payload = params['hl7']['message']
      puts payload
      @url = @@URLS[version]
      # @resp = RestClient.post(@url, payload.gsub!("\n","\r")).chomp()
        # { message: resp}.to_json
#       @resp = "MSH|^~\&|EnsembleHL7|ISC|404|808|201607162206||ACK^A05|218|P|2.4|936
# MSA|AE|218
# ERR||||E|<Ens>ErrGeneral|||ERROR <Ens>ErrGeneral: Not forwarding message 9292 with message body Id=4610, Doc Identifier=218, SessionId=9292 because of validation failure: ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 8:DB1.  Field 2, repetition 1 is larger than segment structure 2.4:DB1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ABCDDEFRTYURYRURURUR' appears in segment 8:DB1, field 2, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:334.\X0D\\X0A\+\X0D\\X0A\ERROR"
# ERR||||E|<Ens>ErrGeneral|||ERROR <Ens>ErrGeneral: Not forwarding message 9292 with message body Id=4610, Doc Identifier=218, SessionId=9292 because of validation failure: ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 8:DB1.  Field 2, repetition 1 is larger than segment structure 2.4:DB1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ABCDDEFRTYURYRURURUR' appears in segment 8:DB1, field 2, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:334.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 6, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'xxxxxxxxxx' appears in segment 11:DG1, field 6, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:52.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 18, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ZZZZZZZ' appears in segment 11:DG1, field 18, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:136."

      #puts @resp.gsub!("\X0D\\X0A", "\n") #mac
      # puts @resp.gsub!("\\X0D\\\\X0A\\", "\n") #windows
      # puts @resp.gsub!("\r+\r", "\r")

      @errors = MsgErrorHandler.new().handle(@resp)
    rescue => e
      @resp = 'Error connecting to ' + @url
      puts e
      # raise e
    end

    # send response
    {message: @resp, errors: @errors}.to_json
  end

  # https://code.google.com/p/x2js/ as an alternative
  get '/lookup/' do
    versions_to_client = {}

    begin
      versions = ProfileParser.lookup_versions()
      # puts cache_lookup('hW')

      std_arr =[]
      versions.each{ |version|
        std_attrs={}
        # standard
        std_attrs[:std] = version[:std]
        #versions
        std_attrs[:versions] = version[:profiles].inject([]){|col,p| col << {name: p[:doc], code: p[:name], desc: (p[:std])? 'Base': p[:description]}}
        #events
        evn_attrs = version[:profiles].inject({}){|h,p|
          h.merge({p[:name] => ProfileParser.new({std: version[:std], version: p[:doc], version_store: versions}).lookup_message_groups(@@FILTERS)})
        }
        std_attrs[:events] = evn_attrs
        # add map with versions and events for each standard to the array
        std_arr << std_attrs
      }

      versions_to_client = {standards: std_arr}
      # pth = File.join(File.dirname(__FILE__), "v_items_mock.json")
      # txt = File.read(pth)
      # versions_to_client = JSON.parse(txt)
      # versions_to_client.to_json

      # p event_list
      p 'in lookup'
    rescue => e
        puts e
    end
    versions_to_client.to_json
     # items = {standards:[
     #     {std:'2.4',
     #      versions:[{'name'=> '2.4', 'code'=> '2.4', 'desc'=>'Base'},{'name' =>'VAZ 2.4', 'code'=> 'vaz2.4', 'desc'=>'2.4 schema with VA defined tables and Z segments'}],
     #      events: {'2.4' => event_list['2.4'], 'vaz2.4' => event_list['vaz2.4']}
     #     },
     #     {std:'2.5', versions:[], events:[]}
     # ]}
     # items.to_json

  end

  # error do
  #   puts 'inside error'
  #   # 'Sorry there was a nasty error - ' + env['sinatra.error'].message
  # end

  # def cache_lookup(key)
  #   begin
  #     value = $diskcache.get(key)
  #   rescue Diskcached::NotFound => e # prevents easy replacement, but is safer.
  #     case key
  #       when 'version_store'
  #         value = ProfileParser.lookup_versions()
  #       else
  #         value  = 'Hello World'
  #     end
  #     if(value) then $diskcache.set(key, value) end
  #   end
  #   return value
  # end


  # $0 is the executed file
  # __FILE__ is the current file
  run! if __FILE__ == $0
end
 # HELPER METHODS
 # cache lookup method
