# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'
require 'json'
require 'mysql2'
require 'sinatra/base'

require_relative './poem'
require_relative './fact'
require_relative './painting'
require_relative './oblique_strategy'

require_relative './cover_letter'

require_relative './prospero'

class Main < Sinatra::Base
  def initialize
    super

    dynamo_db_client = Aws::DynamoDB::Client.new({ region: 'us-east-2' })

    poem_bucket = Aws::S3::Bucket.new({ name: 'poem-of-the-day', region: 'us-east-1' })

    @poem = Poem.new(dynamo_db_client, poem_bucket)
    @fact = Fact.new dynamo_db_client
    @painting = Painting.new dynamo_db_client
    @oblique_strategy = ObliqueStrategy.new dynamo_db_client

    cover_letter_bucket = Aws::S3::Bucket.new({ name: 'justin-lee-cover-letter', region: 'us-east-2' })

    @cover_letter = CoverLetter.new cover_letter_bucket

    prospero_bucket = Aws::S3::Bucket.new({ name: 'prospero-texts', region: 'us-east-2' })

    @prospero = Prospero.new prospero_bucket
  end

  before do
    allowed_origins = [/localhost:3000/, /127.0.0.1:8080/, /iamjustinlee.com/]

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

  get '/oblique-strategy' do
    content_type :json
    status 200

    oblique_strategy = @oblique_strategy.get
    JSON.generate(oblique_strategy)
  end

  get '/cover-letter/:company_name' do
    content_type 'text/markdown'
    status 200

    begin
      @cover_letter.get params['company_name']
    rescue CoverLetterValidationException => e
      content_type :json
      status e.status_code
      body JSON.generate message: e.message
    rescue Aws::S3::Errors::NoSuchKey
      content_type :json
      status 404
      body JSON.generate message: 'The company is not found.'
    end
  end

  # Query parameters: pageSize (Numeric), pageNumber (Numeric)
  get '/prospero/texts/:title/:description' do
    content_type :json

    page_number = params['pageNumber'] ? params['pageNumber'].to_i : 1
    page_size = params['pageSize'] ? params['pageSize'].to_i : 10

    begin
      response = @prospero.get(params['title'], params['description'], page_number, page_size)

      if response
        status 200
        body response
      else
        status 404
        body JSON.generate message: 'The text cannot be found.'
      end
    rescue ProsperoValidationException => e
      content_type :json
      status e.status_code
      body JSON.generate message: e.message
    rescue Mysql2::Error
      content_type :json
      status 500
      body JSON.generate message: 'There is an issue with the server. Please contact the owner.'
    rescue Aws::S3::Errors::NoSuchKey
      content_type :json
      status 404
      body JSON.generate message: 'The company is not found.'
    end
  end

  put '/prospero/texts/:title/:description' do
    status 204

    begin
      data = JSON.parse(request.body.read)
      @prospero.update(params['title'], params['description'], data)

      return nil
    rescue JSON::ParserError
      content_type :json
      status 400
      body JSON.generate message: 'Request body should be valid JSON.'
    rescue ProsperoValidationException => e
      content_type :json
      status e.status_code
      body JSON.generate message: e.message
    end
  end
end
