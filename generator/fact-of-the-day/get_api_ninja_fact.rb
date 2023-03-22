def get_api_ninja_fact
    apiKey = ENV['API_NINJA_KEY']
    apiNinjaUrl = 'https://api.api-ninjas.com/v1/facts?limit=1'

    uri = URI.parse(apiNinjaUrl)

    response = Net::HTTP.get(uri, initheader = { 'Content-Type': 'application/json', 'X-Api-Key': apiKey })
    responseJson = JSON.parse response
    content = responseJson[0]['fact']

    content += '.' if !content.end_with? '.'

    {
        source: 'API Ninjas',
        sourceRef: 'https://api-ninjas.com',
        content: content
    }
end