class GuidePlaceAssociations < ActiveRecord::Migration
	def change
		create_table :guide_place_associations do |t|
		    t.integer :guide_id
		    t.integer :place_id
		end

		add_index :guide_place_associations, :guide_id
		add_index :guide_place_associations, :place_id
	end
end
