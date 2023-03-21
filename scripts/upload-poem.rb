require 'aws-sdk-dynamodb'
require 'securerandom'

filename = ARGV[0]

title = nil
author = nil
translator = nil
lines = []

enumeratedLines = File.foreach(filename).lazy

poem_id = SecureRandom.uuid

title = enumeratedLines.next.strip
author = enumeratedLines.next.strip
translator = enumeratedLines.next.strip

loop {
    line = enumeratedLines.next.strip
    lines += [line]
}
dynamoResource = Aws::DynamoDB::Resource.new

table = dynamoResource.table('Poem')

table.put_item({
    item: {
        title: title,
        author: author,
        translator: translator,
        lines: lines,
        poem_id: poem_id
    }
})
