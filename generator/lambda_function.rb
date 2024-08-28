# frozen_string_literal: true

require 'json'
require 'aws-sdk-dynamodb'

require_relative './poem-of-the-day/update_poem_of_the_day'
require_relative './fact-of-the-day/update_fact_of_the_day'
require_relative './painting-of-the-day/update_painting_of_the_day'
require_relative './oblique_strategy_of_the_day/update_oblique_strategy_of_the_day'
require_relative './frog_sound_of_the_day/update_frog_sound_of_the_day'

def lambda_handler(*)
  dynamo_client = Aws::DynamoDB::Client.new({ region: 'us-east-2' })

  threads = []

  threads += [
    Thread.new { update_poem_of_the_day dynamo_client },
    Thread.new { update_fact_of_the_day dynamo_client },
    Thread.new { update_painting_of_the_day dynamo_client },
    Thread.new { update_oblique_strategy_of_the_day dynamo_client }
    Thread.new { update_frog_sound_of_the_day dynamo_client }
  ]

  threads.each(&:join)

  { statusCode: 200, body: JSON.generate({}) }
end
