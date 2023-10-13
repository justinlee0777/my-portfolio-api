#!/usr/bin/env ruby

# frozen_string_literal: true

require 'aws-sdk-dynamodb'
require 'aws-sdk-s3'
require 'securerandom'

filename = ARGV[0]
upload_to_s3 = ARGV[1] == 'upload-to-s3'

dynamo_client = Aws::DynamoDB::Client.new

result = dynamo_client.scan(
  {
    table_name: 'Poem',
    projection_expression: 'poem_id',
    expression_attribute_names: {
      '#pid': 'poem_id'
    },
    expression_attribute_values: {
      ':poemOfTheDay': 'poem-of-the-day'
    },
    filter_expression: '#pid <> :poemOfTheDay'
  }
)

lines = []

enumerated_lines = File.foreach(filename).lazy

title = enumerated_lines.next.rstrip
author = enumerated_lines.next.rstrip
translator = enumerated_lines.next.rstrip

loop do
  line = enumerated_lines.next.rstrip
  lines += [line]
end

if upload_to_s3
  poem_bucket = Aws::S3::Bucket.new({ name: 'poem-of-the-day', region: 'us-east-1' })

  object_name = "#{title} by #{author}"

  poem_bucket.put_object({
                           key: object_name,
                           body: lines.join("\n")
                         })

  put_request_item = {
    title: title,
    author: author,
    translator: translator,
    object_name: object_name,
    poem_id: result['items'].length.to_s
  }
else
  put_request_item = {
    title: title,
    author: author,
    translator: translator,
    lines: lines,
    poem_id: result['items'].length.to_s
  }
end

dynamo_client.put_item({
                         item: put_request_item,
                         table_name: 'Poem'
                       })
