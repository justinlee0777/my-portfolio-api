def update_fact_of_the_day(dynamo_resource)
    apiKey = ENV['API_NINJA_KEY']
    apiNinjaUrl = 'https://api.api-ninjas.com/v1/facts?limit=1'

    uri = URI.parse(apiNinjaUrl)

    response = Net::HTTP.get(uri, initheader = { 'Content-Type': 'application/json', 'X-Api-Key': apiKey })
    responseJson = JSON.parse response
    content = responseJson[0]['fact']

    content += '.' if !content.end_with? '.'

    apiNinjaDisplayName = 'API Ninjas'
    apiNinjaWebPage = 'https://api-ninjas.com'

    table = dynamo_resource.table('Facts')

    table.update_item({
        key: {
            fact_id: 'fact-of-the-day'
        },
        expression_attribute_names: {
            '#Source': 'source',
            '#SourceRef': 'sourceRef',
            '#Content': 'content',
        }, 
        expression_attribute_values: {
            ':source': apiNinjaDisplayName,
            ':sourceRef': apiNinjaWebPage,
            ':content': content
        }, 
        update_expression: 'SET #Source = :source, #SourceRef = :sourceRef, #Content = :content' 
    })
end