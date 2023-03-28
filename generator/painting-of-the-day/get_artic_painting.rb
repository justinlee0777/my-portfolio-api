# frozen_string_literal: true

def get_artic_painting
  art_institute_chicago_api_url = 'https://api.artic.edu/api/v1'

  search_url = "#{art_institute_chicago_api_url}/artworks/search?size=1"

  query = {
    q: 'painting',
    size: 1
  }

  headers = { 'Content-Type': 'application/json' }

  describe_response = HTTParty.get(search_url, query: query, headers: headers)

  total_artworks = describe_response['pagination']['total']

  # The API seems unable to get a page beyond 999, so we will need to limit it here, if necessary

  upper_bound = [total_artworks, 999].min

  painting_index = rand upper_bound

  query[:from] = painting_index

  artworks_response = HTTParty.get(search_url, query: query, headers: headers)

  artwork_url = artworks_response['data'][0]['api_link']

  query = {
    fields: %w[artist_title date_end id title image_id]
  }

  artwork_response = HTTParty.get(artwork_url, query: query, headers: headers)

  artwork = artwork_response['data']

  image_url_partial = "#{artwork_response['config']['iiif_url']}/#{artwork['image_id']}/full"

  {
    title: artwork['title'],
    artist: artwork['artist_title'],
    dateOfCreation: artwork['date_end'],
    images: {
      highRes: "#{image_url_partial}/1686,/0/default.jpg",
      inline: "#{image_url_partial}/400,/0/default.jpg"
    },
    credit: 'Art Institute of Chicago',
    creditRef: 'https://api.artic.edu/docs'
  }
end
