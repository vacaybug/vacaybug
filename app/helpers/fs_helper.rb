# FourSquare API
module FsHelper
    def search near_location, query
    	url = "https://api.foursquare.com/v2/venues/search?v=20150101"
    	url += "&client_id=#{Rails.configuration.foursquare[:client_id]}"
    	url += "&client_secret=#{Rails.configuration.foursquare[:client_secret]}"
    	url += "&query=#{CGI.escape(query)}"
    	url += "&near=#{CGI.escape(near_location)}"

    	response = HTTParty.get(url)
    	JSON.parse(response.body)["response"]
    end

    def get_photos venue_id, max_count=10
    	url = "https://api.foursquare.com/v2/venues/#{venue_id}/photos?v=20150101"
    	url += "&client_id=#{Rails.configuration.foursquare[:client_id]}"
    	url += "&client_secret=#{Rails.configuration.foursquare[:client_secret]}"
    	response = HTTParty.get(url)
    	JSON.parse(response.body)["response"]["photos"]["items"].slice(0, max_count)
    end
end
