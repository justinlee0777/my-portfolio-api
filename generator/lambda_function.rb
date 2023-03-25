require "json"
require "aws-sdk-dynamodb"

require_relative "./poem-of-the-day/update_poem_of_the_day"
require_relative "./fact-of-the-day/update_fact_of_the_day"

def lambda_handler(event:, context:)
  dynamo_resource = Aws::DynamoDB::Resource.new({ region: "us-east-2" })

  threads = []

  threads += [
    Thread.new { update_poem_of_the_day dynamo_resource },
    Thread.new { update_fact_of_the_day dynamo_resource }
  ]

  threads.each { |thread| thread.join }

  { statusCode: 200, body: JSON.generate({}) }
end
