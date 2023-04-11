# frozen_string_literal: true

class ObliqueStrategy
  def initialize(client)
    @client = client
  end

  def get
    response =
      @client.get_item(
        { table_name: 'oblique_strategies', key: { oblique_strategy_id: 'oblique_strategy_of_the_day' } }
      )
    response['item']
  end
end
