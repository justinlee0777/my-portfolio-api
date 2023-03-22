def update_poem_of_the_day(dynamo_resource)
    table = dynamo_resource.table('Poem')

    poemIds = table.scan({
        projection_expression: 'poem_id',
        expression_attribute_names: {
            '#pid': 'poem_id'
        },
        expression_attribute_values: {
            ':poemOfTheDay':  'poem-of-the-day'
        },
        filter_expression: '#pid <> :poemOfTheDay'
    })

    poemIndex = rand(poemIds['count'])

    poemId = poemIds['items'][poemIndex]['poem_id']

    poemResponse = table.get_item({
        table_name: 'Poem',
        key: {
            poem_id: poemId
        }
    })
    poem = poemResponse['item']

    table.update_item({
        key: {
            poem_id: 'poem-of-the-day'
        },
        expression_attribute_names: {
            '#Title': 'title',
            '#Author': 'author',
            '#Translator': 'translator',
            '#Lines': 'lines'
        },
        expression_attribute_values: {
            ':title': poem['title'],
            ':author': poem['author'],
            ':translator': poem['translator'],
            ':lines': poem['lines']
        },
        update_expression: 'SET #Title = :title, #Author = :author, #Translator = :translator, #Lines = :lines',
    })
end