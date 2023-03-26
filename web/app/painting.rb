# frozen_string_literal: true

require 'net/http'
require 'json'

class Painting
  def initialize(client)
    @client = client
  end

  def get
    response =
      @client.get_item(
        { table_name: 'Paintings', key: { painting_id: 'painting-of-the-day' } }
      )
    response['item']
  end
end
