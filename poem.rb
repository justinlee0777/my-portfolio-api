# typed: true

require 'sorbet-runtime'

require 'HTTParty'

module Poem
    class Random
        extend T::Sig
      
        sig {params(pstore: PStore).void}
        def initialize(pstore)
          @pstore = pstore
          update()
        end
      
        sig {void}
        def update
          @request = Thread.new {
            response = HTTParty.get('https://poetrydb.org/random')
            content = response[0]['lines'].join("\n")
            @pstore.transaction do
              @pstore[:poem] = {
                :content => content
              }
            end
          }
        end
      
        sig {returns(String)}
        def get
          @request.join
          @pstore.transaction true do
            @pstore[:poem][:content]
          end
        end
    end
end