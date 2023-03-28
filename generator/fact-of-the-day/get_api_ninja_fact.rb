# frozen_string_literal: true

require 'httparty'

def get_api_ninja_fact
  api_key = ENV.fetch('API_NINJA_KEY', nil)
  api_ninja_url = 'https://api.api-ninjas.com/v1/facts?limit=1'

  response = HTTParty.get(
    api_ninja_url,
    headers: {
      'Content-Type': 'application/json',
      'X-Api-Key': api_key
    }
  )

  content = response[0]['fact']

  content += '.' unless content.end_with? '.'

  {
    source: 'API Ninjas',
    sourceRef: 'https://api-ninjas.com',
    content: content
  }
end
