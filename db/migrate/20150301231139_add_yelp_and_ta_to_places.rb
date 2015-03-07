class AddYelpAndTaToPlaces < ActiveRecord::Migration
	def change
		add_column :places, :yelp, :text
		add_column :places, :trip_advisor, :text
	end
end
