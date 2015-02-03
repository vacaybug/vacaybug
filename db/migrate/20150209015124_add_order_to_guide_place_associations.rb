class AddOrderToGuidePlaceAssociations < ActiveRecord::Migration
	def change
		add_column :guide_place_associations, :order, :integer
	end
end
