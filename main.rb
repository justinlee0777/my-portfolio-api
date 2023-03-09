# typed: true

require 'sorbet-runtime'

require 'sinatra'
require "pstore"

require './poem.rb'

pstore = PStore.new('myapp.pstore')

poem = Poem::Random.new(pstore)

Sinatra::Base.get '/hello/:thing' do |thing|
  "Hello #{thing}!"
end

Sinatra::Base.get '/poem' do
  poem.get
end
