# frozen_string_literal: true

require_relative 'get_api_ninja_fact'
require_relative 'get_useless_fact'

def update_fact_of_the_day(dynamo_client)
  api_sources = [
    'API Ninja',
    'uselessfact'
  ]

  index = rand api_sources.length

  case index
  when 0
    fact = get_api_ninja_fact
  when 1
    fact = get_useless_fact
  end

  dynamo_client.update_item(
    {
      table_name: 'Facts',
      key: {
        fact_id: 'fact-of-the-day'
      },
      expression_attribute_names: {
        '#Source': 'source',
        '#SourceRef': 'sourceRef',
        '#Content': 'content'
      },
      expression_attribute_values: {
        ':source': fact[:source],
        ':sourceRef': fact[:sourceRef],
        ':content': fact[:content]
      },
      update_expression:
        'SET #Source = :source, #SourceRef = :sourceRef, #Content = :content'
    }
  )
end
