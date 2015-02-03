class CreateGuide < ActiveRecord::Migration
	def change
		create_table :guides do |t|
		    t.integer :privacy
		    t.string  :country
		    t.string  :city
		    t.string  :region
		    t.integer :geonames_id

		    t.timestamps
		end
	end
end
