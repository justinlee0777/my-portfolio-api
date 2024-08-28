# frozen_string_literal: true

require 'httparty'
require 'base64'

def update_frog_sound_of_the_day(dynamo_client)
  client_id = ENV.fetch('SPOTIFY_CLIENT_ID', nil)
  client_secret = ENV.fetch('SPOTIFY_CLIENT_SECRET', nil)

  auth_url = 'https://accounts.spotify.com/api/token'

  auth_body = {
    grant_type: 'client_credentials'
  }

  token = Base64.strict_encode64("#{client_id}:#{client_secret}")

  auth_headers = {
    Authorization: "Basic #{token}"
  }

  response = HTTParty.post(auth_url, body: auth_body, headers: auth_headers)

  access_token = response['access_token']

  frog_sounds_album_id = '5tM75Ja4m0O1k6aeWPRwvp'

  tracks_url = "https://api.spotify.com/v1/albums/#{frog_sounds_album_id}/tracks"

  tracks_headers = {
    Authorization: "Bearer #{access_token}"
  }

  tracks_response = HTTParty.get(tracks_url, headers: tracks_headers)

  total = tracks_response['total']

  index = rand total

  index += 1

  tracks_query = {
    limit: 1,
    offset: index
  }

  track_response = HTTParty.get(tracks_url, headers: tracks_headers, query: tracks_query)

  spotify_track_id = track_response['items'][0]['id']

  dynamo_client.update_item(
    {
      table_name: 'frog_sounds',
      key: {
        frog_sound_id: 'frog-sound-of-the-day'
      },
      expression_attribute_names: {
        '#spotify_track_id': 'spotify_track_id'
      },
      expression_attribute_values: {
        ':spotify_track_id': spotify_track_id
      },
      update_expression:
        'SET #spotify_track_id = :spotify_track_id'
    }
  )
end
