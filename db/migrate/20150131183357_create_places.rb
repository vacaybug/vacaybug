class CreatePlaces < ActiveRecord::Migration
	def change
		create_table :places do |t|
		    t.text		:fs_data
		    t.string	:phone
		    t.string    :title
		    t.text      :address

		    t.integer   :geonames_id
		    t.string    :country
		    t.string    :region
		    t.string    :city

		    t.timestamps
		end
	end
end
