# frozen_string_literal: true

require 'httparty'

def get_useless_fact
  useless_fact_url = 'https://uselessfacts.jsph.pl/api/v2/facts/random'

  response = HTTParty.get(
    useless_fact_url,
    headers: { 'Content-Type': 'application/json' }
  )

  content = response['text']

  {
    source: 'uselessfacts',
    sourceRef: 'https://uselessfacts.jsph.pl',
    content: content
  }
end
