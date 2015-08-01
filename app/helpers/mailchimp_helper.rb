module MailchimpHelper
	def subscribe email
		params = {
			apikey: Rails.configuration.mailchimp[:api_key],
			id: Rails.configuration.mailchimp[:list_id],
			email: {
				email: email
			},
			double_optin: false
		}
		puts params

		HTTParty.post("https://us9.api.mailchimp.com/2.0/lists/subscribe", query: params)
	end
end
