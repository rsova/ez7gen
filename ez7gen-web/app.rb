require 'sinatra'
require 'json'
require 'rest_client'
require 'ez7gen'
@@URLS={'2.4'=>'localhost:8890/','vaz2.4'=>'localhost:8891/'}

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
    # hl7
    begin
      puts 'inside begin'
      # no additional configuration needed for angularjs,
      params = JSON.parse(request.env["rack.input"].read)
      puts  params
      event =  params['event']['selected']['code']
      version =  params['version']['selected']['code']
      puts event
      puts version
      msg = MessageFactory.new
      @hl7 = msg.generate(version, event)#msg.replace('\r','\n' )
    rescue
      puts 'inside rescue'
      @hl7='Oops, somenthing went wrong..'
    end
    {message: @hl7}.to_json
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
      resp = RestClient.post url, payload
        { message: resp}.to_json
    rescue
      resp = 'Error connecting to ' + url
    end
    { message: resp}.to_json
  end

