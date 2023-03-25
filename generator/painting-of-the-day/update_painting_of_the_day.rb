require_relative 'get_met_painting'

def update_painting_of_the_day(dynamo_resource)
  painting = get_met_painting

  table = dynamo_resource.table('Paintings')

  table.update_item(
    {
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
      update_expression:
        'SET #Title = :title, #Artist = :artist, #DateOfCreation = :dateOfCreation, #Country = :country, #City = :city, #Images = :images, #Credit = :credit, #CreditRef = :creditRef'
    }
  )
end
