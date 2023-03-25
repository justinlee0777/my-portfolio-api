require "httparty"

def get_api_ninja_fact
  apiKey = ENV["API_NINJA_KEY"]
  apiNinjaUrl = "https://api.api-ninjas.com/v1/facts?limit=1"

  response =
    HTTParty.get(
      apiNinjaUrl,
      headers: {
        "Content-Type": "application/json",
        "X-Api-Key": apiKey
      }
    )

  content = response[0]["fact"]

  content += "." if !content.end_with? "."

  {
    source: "API Ninjas",
    sourceRef: "https://api-ninjas.com",
    content: content
  }
end
