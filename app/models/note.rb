class Note < ActiveRecord::Base
	attr_accessible :user_id, :place_id, :note

	def self.find_note user_id, place_id
		note = Note.where(user_id: user_id, place_id: place_id).first
		if note
			note
		else
			Note.create(user_id: user_id, place_id: place_id, note: "")
		end
	end
end
