# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'securerandom'

filename = ARGV[0]

lines = []

enumerated_lines = File.foreach(filename).lazy

poem_id = SecureRandom.uuid

title = enumerated_lines.next.rstrip
author = enumerated_lines.next.rstrip
translator = enumerated_lines.next.rstrip

loop do
  line = enumerated_lines.next.rstrip
  lines += [line]
end
dynamo_resource = Aws::DynamoDB::Resource.new

table = dynamo_resource.table('Poem')

table.put_item(
  {
    item: {
      title: title,
      author: author,
      translator: translator,
      lines: lines,
      poem_id: poem_id
    }
  }
)
