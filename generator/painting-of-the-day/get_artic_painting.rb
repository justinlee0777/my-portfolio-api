# frozen_string_literal: true

def get_artic_painting
  artInstituteChicagoApiUrl = 'https://api.artic.edu/api/v1'

  searchUrl = "#{artInstituteChicagoApiUrl}/artworks/search?size=1"

  query = {
    q: 'painting',
    size: 1
  }

  headers = { 'Content-Type': 'application/json' }

  describeResponse = HTTParty.get(searchUrl, query: query, headers: headers)

  totalArtworks = describeResponse['pagination']['total']

  # The API seems unable to get a page beyond 999, so we will need to limit it here, if necessary

  upperBound = [totalArtworks, 999].min

  paintingIndex = rand upperBound

  query[:from] = paintingIndex

  artworksResponse = HTTParty.get(searchUrl, query: query, headers: headers)

  artworkUrl = artworksResponse['data'][0]['api_link']

  query = {
    fields: %w[artist_title date_end id title image_id]
  }

  artworkResponse = HTTParty.get(artworkUrl, query: query, headers: headers)

  artwork = artworkResponse['data']

  imageUrlPartial = "#{artworkResponse['config']['iiif_url']}/#{artwork['image_id']}/full"

  {
    title: artwork['title'],
    artist: artwork['artist_title'],
    dateOfCreation: artwork['date_end'],
    images: {
      highRes: "#{imageUrlPartial}/1686,/0/default.jpg",
      inline: "#{imageUrlPartial}/400,/0/default.jpg"
    },
    credit: 'Art Institute of Chicago',
    creditRef: 'https://api.artic.edu/docs'
  }
end
