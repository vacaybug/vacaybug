class CreateCities < ActiveRecord::Migration
	def change
		create_table :cities do |t|
			t.integer :gn_id
			t.text :gn_data
			t.string :city
			t.string :region
			t.string :country

		    t.timestamps
		end

		add_index :cities, :gn_id
	end
end
