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

    dynamo_db_client = Aws::DynamoDB::Client.new

    @poem = Poem.new dynamo_db_client
    @fact = Fact.new dynamo_db_client
    @painting = Painting.new dynamo_db_client

    @cover_letter_bucket = Aws::S3::Bucket.new 'justin-lee-cover-letter'
  end

  before do
    allowed_origins = [/localhost:3000/, /iamjustinlee.com/]

    origin = request.get_header 'HTTP_ORIGIN'
    headers 'Access-Control-Allow-Methods': 'GET'

    if !origin.nil? && allowed_origins.any? { |allowed_origin| allowed_origin.match origin }
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

    object_name = "#{params['company_name']}.md"

    begin
      @cover_letter_bucket.object(object_name).get['body']
    rescue Aws::S3::Errors::NoSuchKey
      content_type 'application/json'
      status 404
      body JSON.generate message: "Resource not found: #{object_name}"
    end
  end
end
