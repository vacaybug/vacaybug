class AddFsIdToPlaces < ActiveRecord::Migration
 	def change
 		add_column :places, :fs_id, :string
 	end
end
