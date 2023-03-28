# frozen_string_literal: true

require 'httparty'

def get_met_painting
  met_museum_api_url = 'https://collectionapi.metmuseum.org/public/collection/v1'

  search_url = "#{met_museum_api_url}/search"

  query = {
    # It appears that 'q' is required, even if it is empty
    q: '',
    medium: 'Paintings',
    hasImages: true,
    isPublicDomain: true
  }

  headers = { 'Content-Type': 'application/json' }

  objects_response = HTTParty.get(search_url, query: query, headers: headers)

  random_object_id = objects_response['objectIDs'][rand objects_response['total']]

  object_url = "#{met_museum_api_url}/objects/#{random_object_id}"

  object_response = HTTParty.get(object_url, headers: headers)

  {
    title: object_response['title'],
    artist: object_response['artistDisplayName'],
    dateOfCreation: object_response['objectDate'],
    country: object_response['country'],
    city: object_response['city'],
    images: {
      highRes: object_response['primaryImage'],
      inline: object_response['primaryImageSmall']
    },
    credit: 'Metropolitan Museum of Art',
    creditRef: 'https://metmuseum.github.io'
  }
end
