class Place < ActiveRecord::Base
	attr_accessible :phone, :title, :address, :geonames_id, :country, :region, :city, :fs_data, :fs_id
	serialize :fs_data, JSON

	after_destroy :delete_associations

	def delete_associations
		GuidePlaceAssociation.where(:place_id => self.id).destroy_all
	end

	def photo
		item = fs_data["photos"][0]
		return nil if !item

		{ prefix: item["prefix"], suffix: item["suffix"] }
	end

	def get_note guide
		note = Note.where(user_id: guide.user_id, place_id: self.id).first
		if note
			note.note
		else
			""
		end
	end

	def as_json(options = {})
	    options.merge!({methods: [:photo], except: [:fs_data]})

	    json = super(options)
	    json["note"] = get_note(options[:guide]) if options[:guide]
	    json["location"] = fs_data["location"]
	    json
	end
end
