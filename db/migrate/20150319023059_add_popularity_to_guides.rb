class AddPopularityToGuides < ActiveRecord::Migration
 	def change
 		add_column :guides, :popularity, :integer, default: 0
 		add_index :guides, :geonames_id
 		add_index :guides, :popularity
 		add_index :guides, [:popularity, :geonames_id]
 	end
end
