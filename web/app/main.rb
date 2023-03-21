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

    get '/poem' do
        poem = @poem.get
        JSON.generate(poem)
    end
end
