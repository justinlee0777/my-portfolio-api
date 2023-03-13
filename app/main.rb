require 'json'

require_relative './poem.rb'

class Main
  def call env
    headers = {'content-type' => 'text/plain'}

    if env['REQUEST_METHOD'] != 'GET'
      [405, headers, ['Method not supported.']]
    elsif env['REQUEST_PATH'] =~ /\/poem/
      headers = {'content-type' => 'application/json'}
      poem = Poem.get
      [200, headers, [ JSON.generate(poem) ]]
    else
      [404, headers, ['No resource founded.']]
    end
  end
end