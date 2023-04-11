# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'securerandom'

filename = ARGV[0]

enumerated_lines = File.foreach(filename).lazy

dynamo_resource = Aws::DynamoDB::Resource.new

table = dynamo_resource.table('oblique_strategies')

loop do
  strategy_id = SecureRandom.uuid
  content = enumerated_lines.next.rstrip
  table.put_item(
    {
      item: {
        oblique_strategy_id: strategy_id,
        content: content
      }
    }
  )
end
