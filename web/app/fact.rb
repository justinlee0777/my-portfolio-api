require 'net/http'
require 'json'

class Fact
  def initialize(client)
    @client = client
  end

  def get
    response =
      @client.get_item(
        { table_name: 'Facts', key: { fact_id: 'fact-of-the-day' } }
      )
    response['item']
  end
end
