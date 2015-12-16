require 'sinatra'
require 'json'
require 'rest_client'
require 'ez7gen'
# require_relative '../lib/ez7gen/message_factory' # local testing

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
      puts "event: #{event}, version: #{version}"

      msg = MessageFactory.new
      @hl7 = msg.generate(version, event)#msg.replace('\r','\n' )
    rescue => e
      puts 'inside rescue'
      puts e
      @hl7='Oops, somenthing went wrong..'
    #ensure
    end

    # send response
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
      resp = RestClient.post url, payload.gsub!("\n","\r")
        # { message: resp}.to_json
    rescue => e
      puts e
      resp = 'Error connecting to ' + url
    end

    # send response
    {message: resp}.to_json
  end

  # https://code.google.com/p/x2js/ as an alternative
  # post '/lookup/' do
  #     begin
  #     params = JSON.parse(request.env["rack.input"].read)
  #     puts params
  #     version =  params['version']['selected']['code']
  #     filter = params['filter']
  #     rescue
  #     end
  #
  # end

