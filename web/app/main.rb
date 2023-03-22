require 'aws-sdk-dynamodb'
require 'sinatra/base'
require 'json'

require_relative './poem.rb'

class Main < Sinatra::Base
    def initialize
        super

        client = Aws::DynamoDB::Client.new({ region: 'us-east-2' })

        @poem = Poem.new client
    end

    before do
        allowedOrigins = [
            /localhost:3000/,
            /iamjustinlee.com/
        ]

        origin = request.get_header 'HTTP_ORIGIN'
        headers 'Access-Control-Allow-Methods': 'GET'

        if origin != nil
            headers 'Access-Control-Allow-Origin': origin if allowedOrigins.any? { |allowedOrigin| allowedOrigin.match origin }
        end
    end

    get '/poem' do
        content_type :json

        poem = @poem.get
        JSON.generate(poem)
    end
end