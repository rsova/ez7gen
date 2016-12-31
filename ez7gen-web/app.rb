# require 'sinatra'
require 'sinatra/base'

require 'json'
require 'rest_client'
# require 'diskcached'

# to specify version
#gem 'ez7gen', '>= 4.0.0'
# require 'ez7gen'

require_relative '../lib/ez7gen/message_factory' # local testing
require_relative '../lib/ez7gen/profile_parser' # local testing
require_relative '../lib/ez7gen/msg_error_handler' # local testing

class MyApp < Sinatra::Application
  VERSON_IN_DEV = "Oops, versions above 2.4 are still in development ..."

#configure do
#   set :port, 9494
#   set :show_exceptions, :after_handler
#   disable :raise_errors
#end

# @@URLS={'2.4'=>'localhost:9980/','VAZ2.4'=>'localhost:9981/'}
# admisson messages match pattern
# @@FILTERS = [ProfileParser::FILTER_ADM, ProfileParser::FILTER_FM, ProfileParser::FILTER_GEN,  ProfileParser::FILTER_LAB, ProfileParser::FILTER_MSR, ProfileParser::FILTER_OBS, ProfileParser::FILTER_PH]

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

  post '/generate/' do
    begin
      # no additional configuration needed for angularjs,
      params = JSON.parse(request.env["rack.input"].read)
      puts  params

      std = params['std']
      if(std > '2.4') then raise ArgumentError, VERSON_IN_DEV end

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
      @resp = (e.message == VERSON_IN_DEV)? VERSON_IN_DEV: 'Oops, somenthing went wrong...'
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
      std =  params['std']
      schemaName =  params['version']['name']
      puts schemaName
      payload = params['hl7']['message']
      puts payload
      # @url = @@URLS[version]
      @url = ProfileParser.getVersionUrlRule(std,schemaName)
      puts @url
      @resp = RestClient.post(@url, payload.gsub!("\n","\r")).chomp()
#       @resp = "MSH|^~\&|EnsembleHL7|ISC|404|808|201607162206||ACK^A05|218|P|2.4|936
# MSA|AE|218
# ERR||||E|<Ens>ErrGeneral|||ERROR <Ens>ErrGeneral: Not forwarding message 9292 with message body Id=4610, Doc Identifier=218, SessionId=9292 because of validation failure: ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 8:DB1.  Field 2, repetition 1 is larger than segment structure 2.4:DB1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ABCDDEFRTYURYRURURUR' appears in segment 8:DB1, field 2, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:334.\X0D\\X0A\+\X0D\\X0A\ERROR"
# ERR||||E|<Ens>ErrGeneral|||ERROR <Ens>ErrGeneral: Not forwarding message 9292 with message body Id=4610, Doc Identifier=218, SessionId=9292 because of validation failure: ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 8:DB1.  Field 2, repetition 1 is larger than segment structure 2.4:DB1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ABCDDEFRTYURYRURURUR' appears in segment 8:DB1, field 2, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:334.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 6, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'xxxxxxxxxx' appears in segment 11:DG1, field 6, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:52.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Field size restriction exceeded in segment 11:DG1.  Field 18, repetition 1 is larger than segment structure 2.4:DG1 permits it to be.\X0D\\X0A\+\X0D\\X0A\ERROR <Ens>ErrGeneral: Invalid value 'ZZZZZZZ' appears in segment 11:DG1, field 18, repetition 1, component 1, subcomponent 1, but does not appear in code table 2.4:136."
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

      standards =[]

      versions.each{ |version|
        standard_attrs={}

        # standard
        standard_attrs[:std] =  version[:std] # base standard like 2.4 or 2.5

        #versions
        standard_attrs[:versions] = version[:profiles].inject([]){|col, profile|
          col << {name: profile[:doc],
                  code: profile[:name],
                  base: profile.key?(:std), # set base flag true
                  desc: (profile[:std]) ? 'Base': profile[:description]}} # base profile don't have description as a rule

        #events for each version
        version_events = version[:profiles].inject({}){|events, profile|

          exclusions = ProfileParser.getExclusionFilterRule(version[:std], profile[:doc])
          lookup_params = (exclusions.any?) ? {:exclusions => exclusions} : {}

          # if(!profile[:std].nil?) # Base profile has set flag for std
          if(profile.key?(:std)) # Base profile has set flag for std
            #events.merge({profile[:name] => ProfileParser.new({std: version[:std], version: profile[:doc], version_store: versions}).lookup_message_types(filter_map, exclusions)})
            events.merge({profile[:name] =>  ProfileParser.new({std: version[:std], version: profile[:doc], version_store: versions}).lookup_events(lookup_params)})
          else
            lookup_params[:templates_path] =  File.expand_path("../config/templates/#{version[:std]}/", __FILE__)
            events.merge({profile[:name] =>  ProfileParser.new({std: version[:std], version: profile[:doc], version_store: versions}).lookup_events(lookup_params)})
          end

        }
        # add events to the standard attributes
        standard_attrs[:events] = version_events

        # add collection of standards with attributes of each version
        standards << standard_attrs
      }

      versions_to_client = {standards: standards}
      # p event_list
      p 'in lookup'
    rescue => e
      puts e
    end
    versions_to_client.to_json
  end


  # $0 is the executed file
  # __FILE__ is the current file
  run! if __FILE__ == $0
end
