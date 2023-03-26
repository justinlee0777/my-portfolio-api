# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'sinatra/base'
require 'json'

require_relative './poem'
require_relative './fact'
require_relative './painting'

class Main < Sinatra::Base
  def initialize
    super

    client = Aws::DynamoDB::Client.new({ region: 'us-east-2' })

    @poem = Poem.new client
    @fact = Fact.new client
    @painting = Painting.new client
  end

  before do
    allowedOrigins = [/localhost:3000/, /iamjustinlee.com/]

    origin = request.get_header 'HTTP_ORIGIN'
    headers 'Access-Control-Allow-Methods': 'GET'

    if !origin.nil? && allowedOrigins.any? { |allowedOrigin| allowedOrigin.match origin }
      headers 'Access-Control-Allow-Origin': origin
    end
  end

  get '/poem' do
    content_type :json

    poem = @poem.get
    JSON.generate(poem)
  end

  get '/fact' do
    content_type :json

    fact = @fact.get
    JSON.generate(fact)
  end

  get '/painting' do
    content_type :json

    painting = @painting.get
    JSON.generate(painting)
  end
end
