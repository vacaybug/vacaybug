require 'yelp'

Yelp.client.configure do |config|
	config.consumer_key = Rails.configuration.yelp[:consumer_key]
	config.consumer_secret = Rails.configuration.yelp[:consumer_secret]
	config.token = Rails.configuration.yelp[:token]
	config.token_secret = Rails.configuration.yelp[:token_secret]
end
