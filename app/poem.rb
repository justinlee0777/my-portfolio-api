require 'net/http'
require 'json'

class Poem
  def initialize conn
    @conn = conn
  end

  def get
    result = @conn.query('SELECT PoemAuthor, PoemTitle, PoemLines from poem LIMIT 1')
    firstResult = result.first
    {
      author: firstResult['PoemAuthor'],
      title: firstResult['PoemTitle'],
      lines: JSON.parse(firstResult['PoemLines'])
    }
  end

  # Not used currently. May be moved to its own script.
  def determine
    uri = URI('https://poetrydb.org/random')
    responseString = Net::HTTP.get uri;
    response = JSON.parse responseString
    response[0]
  end
end