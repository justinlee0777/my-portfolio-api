# frozen_string_literal: true

require_relative 'get_met_painting'
require_relative 'get_artic_painting'

def update_painting_of_the_day(dynamo_client)
  api_sources = [
    'Metropolitan Museum of Art',
    'Art Institute of Chicago'
  ]

  index = rand api_sources.length

  case index
  when 0
    painting = get_met_painting
  when 1
    painting = get_artic_painting
  end

  dynamo_client.update_item(
    {
      table_name: 'Paintings',
      key: {
        painting_id: 'painting-of-the-day'
      },
      expression_attribute_names: {
        '#Title': 'title',
        '#Artist': 'artist',
        '#DateOfCreation': 'dateOfCreation',
        '#Country': 'country',
        '#City': 'city',
        '#Images': 'images',
        '#Credit': 'credit',
        '#CreditRef': 'creditRef'
      },
      expression_attribute_values: {
        ':title': painting[:title],
        ':artist': painting[:artist],
        ':dateOfCreation': painting[:dateOfCreation],
        ':country': painting[:country],
        ':city': painting[:city],
        ':images': painting[:images],
        ':credit': painting[:credit],
        ':creditRef': painting[:creditRef]
      },
      update_expression: 'SET #Title = :title, #Artist = :artist, #DateOfCreation = :dateOfCreation, #Country = :country, #City = :city, #Images = :images, #Credit = :credit, #CreditRef = :creditRef'
    }
  )
end
