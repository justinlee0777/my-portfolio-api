# frozen_string_literal: true

def update_poem_of_the_day(dynamo_client)
  table_description = dynamo_client.describe_table({ table_name: 'Poem' })

  index = rand(table_description['table']['item_count'] - 1)

  poem_response =
    dynamo_client.get_item({ table_name: 'Poem', key: { poem_id: index.to_s } })
  poem = poem_response['item']

  dynamo_client.update_item(
    {
      table_name: 'Poem',
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
      update_expression:
        'SET #Title = :title, #Author = :author, #Translator = :translator, #Lines = :lines'
    }
  )
end
