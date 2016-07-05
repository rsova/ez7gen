# require 'sinatra'
require 'sinatra/base'

require 'json'
require 'rest_client'
require 'diskcached'
# require 'ez7gen'
require_relative '../lib/ez7gen/message_factory' # local testing
require_relative '../lib/ez7gen/profile_parser' # local testing

class MyApp < Sinatra::Application

  # configure do
#   set :show_exceptions, :after_handler
#   disable :raise_errors
# end
@@URLS={'2.4'=>'localhost:9980/','VAZ2.4'=>'localhost:9981/'}
# admisson messages match pattern
@@FILTERS = [ProfileParser::FILTER_ADM, ProfileParser::FILTER_PH]


  configure do
    $diskcache = Diskcached.new(File.join(settings.root, 'cache'))
    $diskcache.flush # ensure caches are empty on startup
    #cahe version store
    # MyApp.class.cache_lookup('version_store')
    puts 'in configure'
  end

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

      vs = ProfileParser.lookup_versions()
      @resp = MessageFactory.new({std: std, version: version, event:event, version_store: vs}).generate() #msg.replace('\r','\n' )

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
      @resp = RestClient.post @url, payload.gsub!("\n","\r")
        # { message: resp}.to_json
    rescue => e
      @resp = 'Error connecting to ' + @url
      puts e
      # raise e
    end

    # send response
    {message: @resp}.to_json
  end

  # https://code.google.com/p/x2js/ as an alternative
  get '/lookup/' do
    versions_to_client = {}

    begin
      versions = ProfileParser.lookup_versions()
      puts cache_lookup('hW')

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

  def cache_lookup(key)
    begin
      value = $diskcache.get(key)
    rescue Diskcached::NotFound => e # prevents easy replacement, but is safer.
      case key
        when 'version_store'
          value = ProfileParser.lookup_versions()
        else
          value  = 'Hello World'
      end
      if(value) then $diskcache.set(key, value) end
    end
    return value
  end


  # $0 is the executed file
  # __FILE__ is the current file
  run! if __FILE__ == $0
end
 # HELPER METHODS
 # cache lookup method
