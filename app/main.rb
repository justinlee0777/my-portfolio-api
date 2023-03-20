require 'sinatra/base'
require 'json'

require_relative './poem.rb'

class Main < Sinatra::Base
    get '/poem' do
        poem = Poem.get
        JSON.generate(poem)
    end
end
