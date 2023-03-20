require 'net/http'
require 'json'

class Poem
    def initialize client
      @client = client
    end

    def get
      response = @client.get_item({
        table_name: 'Poem',
        key: {
          poem_id: 'poem-of-the-day'
        }
      })
      response['item']
    end
end