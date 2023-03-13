require 'net/http'
require 'json'

module Poem
    def Poem.get
      uri = URI('https://poetrydb.org/random')
      responseString = Net::HTTP.get uri;
      response = JSON.parse responseString
      response[0]
    end
end