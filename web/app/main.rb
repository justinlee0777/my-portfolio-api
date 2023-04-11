# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'
require 'sinatra/base'
require 'json'

require_relative './poem'
require_relative './fact'
require_relative './painting'
require_relative './oblique_strategy'

require_relative './cover_letter'

class Main < Sinatra::Base
  def initialize
    super

    dynamo_db_client = Aws::DynamoDB::Client.new({ region: 'us-east-2' })

    @poem = Poem.new dynamo_db_client
    @fact = Fact.new dynamo_db_client
    @painting = Painting.new dynamo_db_client
    @oblique_strategy = ObliqueStrategy.new dynamo_db_client

    cover_letter_bucket = Aws::S3::Bucket.new({ name: 'justin-lee-cover-letter', region: 'us-east-2' })

    @cover_letter = CoverLetter.new cover_letter_bucket
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
    rescue Aws::S3::Errors::NoSuchKey => e
      content_type :json
      status 404
      body JSON.generate message: 'The company is not found.'
    end
  end
end
