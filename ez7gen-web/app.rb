require 'sinatra'
require 'json'
require 'rest_client'
# require_relative 'lib-backup/message_factory'
require 'ez7gen'


  post '/' do
    content_type :json
    { message: 'Hello World!' }.to_json
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
    # puts params['action']['selected']['name']
      event =  params['event']['selected']['code']
      version =  params['version']['selected']['code']
      puts event
      puts version
      msg = MessageFactory.new
      @hl7 = msg.generate(version, event)#msg.replace('\r','\n' )
    rescue
      puts 'inside rescue'
      @hl7='Ops, somenthing went wrong..'
    end
    {message: @hl7}.to_json
  end

  post '/validate/' do
    params = JSON.parse(request.env["rack.input"].read)
    puts params
    res = RestClient.post 'localhost:4567/', 'Test'
    puts res
  end

