require 'json'
require 'aws-sdk-dynamodb'

require_relative 'update_poem_of_the_day'

def lambda_handler(event:, context:)
    dynamo_resource = Aws::DynamoDB::Resource.new({ region: 'us-east-2' })

    threads = []

    threads += [ Thread.new { update_poem_of_the_day dynamo_resource } ]

    threads.each { |thread| thread.join }

    { statusCode: 200, body: JSON.generate({}) }
end
