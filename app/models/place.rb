class Place < ActiveRecord::Base
	attr_accessible :phone, :title, :address, :geonames_id, :country, :region, :city, :fs_data, :fs_id, :yelp
	serialize :fs_data, JSON
	serialize :yelp, JSON
	serialize :trip_advisor, JSON

	after_destroy :delete_associations

	def delete_associations
		GuidePlaceAssociation.where(:place_id => self.id).destroy_all
	end

	def photo
		item = fs_data["photos"][0]
		return nil if !item

		{ prefix: item["prefix"], suffix: item["suffix"] }
	end

	def get_note assoc_id
		g = GuidePlaceAssociation.find(assoc_id)
		if g
			g.note
		else
			nil
		end
	end

	def gen_yelp
		require 'yelp'

		begin
			location = {
				latitude: self.fs_data["location"]["lat"],
				longitude: self.fs_data["location"]["lng"]
			}

			response = Yelp.client.search_by_coordinates(location, {
				term: self.title,
				limit: 1
			})

			if response.businesses && response.businesses[0]
				self.yelp = {
					rating: response.businesses[0].rating,
					url: response.businesses[0].url,
					review_count: response.businesses[0].review_count,
				}

				self.save
			end
		rescue
			self.yelp = nil
			self.save
		end
	end

	def as_json(options = {})
	    options.merge!({methods: [:photo], except: [:fs_data]})

	    json = super(options)
	    json["note"] = get_note(options[:assoc_id]) if options[:assoc_id]
	    json["location"] = fs_data["location"]
	    json
	end
end
