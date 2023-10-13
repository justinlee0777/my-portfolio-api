# frozen_string_literal: true

class Poem
  def initialize(dynamodb, bucket)
    @dynamodb = dynamodb
    @bucket = bucket
  end

  def get
    response =
      @dynamodb.get_item(
        { table_name: 'Poem', key: { poem_id: 'poem-of-the-day' } }
      )

    poem = response['item']

    poem.transform_keys! do |key|
      parts = key.split '_'
      (parts[0..0] + parts[1..].collect(&:capitalize)).join
    end

    s3_key = 'objectName'

    if poem[s3_key]
      object = @bucket.object(poem[s3_key]).get

      io = object['body']

      poem['text'] = io.read

      poem.delete s3_key
    end

    poem
  end
end
