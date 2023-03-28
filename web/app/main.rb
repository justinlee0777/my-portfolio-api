# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'
require 'sinatra/base'
require 'json'

require_relative './poem'
require_relative './fact'
require_relative './painting'

class Main < Sinatra::Base
  def initialize
    super

    dynamoDbClient = Aws::DynamoDB::Client.new

    @poem = Poem.new dynamoDbClient
    @fact = Fact.new dynamoDbClient
    @painting = Painting.new dynamoDbClient

    @coverLetterBucket = Aws::S3::Bucket.new 'justin-lee-cover-letter'
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
    status 200

    poem = @poem.get
    JSON.generate(poem)
  end

  get '/fact' do
    content_type :json
    status 200

    fact = @fact.get
    JSON.generate(fact)
  end

  get '/painting' do
    content_type :json
    status 200

    painting = @painting.get
    JSON.generate(painting)
  end

  get '/cover-letter/:company_name' do
    content_type 'text/markdown'
    status 200

    objectName = "#{params['company_name']}.md"

    begin
      @coverLetterBucket.object(objectName).get['body']
    rescue Aws::S3::Errors::NoSuchKey
      content_type 'application/json'
      status 404
      body JSON.generate message: "Resource not found: #{objectName}"
    end
  end
end
