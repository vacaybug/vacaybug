class Place < ActiveRecord::Base
	attr_accessible :phone, :title, :address, :geonames_id, :country, :region, :city, :fs_data, :fs_id
	serialize :fs_data, JSON

	after_destroy :delete_associations

	def delete_associations
		GuidePlaceAssociation.where(:place_id => self.id).destroy_all
	end

	def photo
		item = fs_data["photos"][0]
		return null if !item

		{ prefix: item["prefix"], suffix: item["suffix"] }
	end

	def as_json(options = {})
	    options.merge!({methods: [:photo], except: [:fs_data]})

	    json = super(options)
	    json
	end
end
