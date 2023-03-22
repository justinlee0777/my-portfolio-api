def get_useless_fact
    uselessFactUrl = 'https://uselessfacts.jsph.pl/api/v2/facts/random'

    uri = URI.parse(uselessFactUrl)

    response = Net::HTTP.get(uri, initheader = { 'Content-Type': 'application/json' })
    responseJson = JSON.parse response
    content = responseJson['text']

    content += '.' if !content.end_with? '.'

    {
        source: 'uselessfacts',
        sourceRef: 'https://uselessfacts.jsph.pl/',
        content: content
    }
end