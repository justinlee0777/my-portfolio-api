# frozen_string_literal: true

def update_oblique_strategy_of_the_day(dynamo_client)
  oblique_strategy_ids =
    dynamo_client.scan(
      {
        table_name: 'oblique_strategies',
        projection_expression: 'oblique_strategy_id',
        expression_attribute_names: {
          '#osid': 'oblique_strategy_id'
        },
        expression_attribute_values: {
          ':obliqueStrategyOfTheDay': 'oblique_strategy_of_the_day'
        },
        filter_expression: '#osid <> :obliqueStrategyOfTheDay'
      }
    )

  oblique_strategy_index = rand oblique_strategy_ids['count']

  oblique_strategy_id = oblique_strategy_ids['items'][oblique_strategy_index]['oblique_strategy_id']

  oblique_strategy_response =
    dynamo_client.get_item({ table_name: 'oblique_strategies', key: { oblique_strategy_id: oblique_strategy_id } })
  oblique_strategy = oblique_strategy_response['item']

  dynamo_client.update_item(
    {
      table_name: 'oblique_strategies',
      key: {
        oblique_strategy_id: 'oblique_strategy_of_the_day'
      },
      expression_attribute_names: {
        '#Content': 'content'
      },
      expression_attribute_values: {
        ':content': oblique_strategy['content']
      },
      update_expression:
        'SET #Content = :content'
    }
  )
end
