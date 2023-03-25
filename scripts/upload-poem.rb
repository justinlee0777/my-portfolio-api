require "aws-sdk-dynamodb"
require "securerandom"

filename = ARGV[0]

title = nil
author = nil
translator = nil
lines = []

enumeratedLines = File.foreach(filename).lazy

poem_id = SecureRandom.uuid

title = enumeratedLines.next.rstrip
author = enumeratedLines.next.rstrip
translator = enumeratedLines.next.rstrip

loop do
  line = enumeratedLines.next.rstrip
  lines += [line]
end
dynamoResource = Aws::DynamoDB::Resource.new

table = dynamoResource.table("Poem")

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
