# frozen_string_literal: true

require 'httparty'

def get_met_painting
  metMuseumApiUrl = 'https://collectionapi.metmuseum.org/public/collection/v1'

  searchUrl = "#{metMuseumApiUrl}/search"

  query = {
    # It appears that 'q' is required, even if it is empty
    q: '',
    medium: 'Paintings',
    hasImages: true,
    isPublicDomain: true
  }

  headers = { 'Content-Type': 'application/json' }

  objectsResponse = HTTParty.get(searchUrl, query: query, headers: headers)

  randomObjectId = objectsResponse['objectIDs'][rand objectsResponse['total']]

  objectUrl = "#{metMuseumApiUrl}/objects/#{randomObjectId}"

  objectResponse = HTTParty.get(objectUrl, headers: headers)

  {
    title: objectResponse['title'],
    artist: objectResponse['artistDisplayName'],
    dateOfCreation: objectResponse['objectDate'],
    country: objectResponse['country'],
    city: objectResponse['city'],
    images: {
      highRes: objectResponse['primaryImage'],
      inline: objectResponse['primaryImageSmall']
    },
    credit: 'Metropolitan Museum of Art',
    creditRef: 'https://metmuseum.github.io'
  }
end
