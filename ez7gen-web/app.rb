require 'sinatra'
require 'json'
require 'rest_client'
require 'ez7gen'
require_relative '../lib/ez7gen/message_factory' # local testing
require_relative '../lib/ez7gen/profile_parser' # local testing

# configure do
#   set :show_exceptions, :after_handler
#   disable :raise_errors
# end
@@URLS={'2.4'=>'localhost:8890/','vaz2.4'=>'localhost:8891/'}
# admisson messages match pattern
@@ADM_FILTER = 'ADT_A|QBP_Q2|RSP_K2'

  get '/' do
    # content_type :json
    # { message: 'Hello World!' }.to_json
    redirect '/index.html'
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

      event =  params['event']['selected']['code']
      version =  params['version']['selected']['code']
      puts "event: #{event}, version: #{version}"

      msg = MessageFactory.new
      @resp = msg.generate(version, event)#msg.replace('\r','\n' )
    rescue => e
      # puts 'inside rescue'
      puts 'Error: processing generate/' << e.inspect
      @resp='Oops, somenthing went wrong...'
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
      version =  params['version']['selected']['code']
      puts version
      payload = params['payload']['message']
      puts payload
      url = @@URLS[version]
      @resp = RestClient.post url, payload.gsub!("\n","\r")
        # { message: resp}.to_json
    rescue => e
      @resp = 'Error connecting to ' + url
      puts e
      # raise e
    end

    # send response
    {message: @resp}.to_json
  end

  # https://code.google.com/p/x2js/ as an alternative
  post '/lookup/' do
    event_list = {}

    begin
      params = JSON.parse(request.env["rack.input"].read)
      puts params
      # {"versions"=>[{"name"=>"2.4", "code"=>"2.4"}, {"name"=>"VAZ 2.4", "code"=>"vaz2.4"}]}
      versions =  params['versions']
      # names={'2.4'=>'adm'.to_sym,'vaz2.4'=>'zseg'.to_sym}
      names={'2.4'=>:adm,'vaz2.4'=>:zseg}

      versions.each{|map|
        version = map['code']
        parser = ProfileParser.new(version)
        events = parser.lookup_message_types(@@ADM_FILTER).map!{|it| {name: it, code: it}}
        version_name = names[version]
        event_list[version_name] = events
      }

      p event_list
      # parser = ProfileParser.new('2.4')
      # @eventsList = parser.lookupMessageTypes(@@ADM_FILTER).map!{|it| {name: it, code: it}}

      #generate map for client to populate drop down boxes
      # puts events
      # version =  params['version']['selected']['code']
      # filter = params['filter']
      rescue => e
        puts e
      end

      # event_list.to_json
      {adm: event_list[:adm], zseg: event_list[:zseg] }.to_json
  end

  # error do
  #   puts 'inside error'
  #   # 'Sorry there was a nasty error - ' + env['sinatra.error'].message
  # end