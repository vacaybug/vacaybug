class ChangeLikes < ActiveRecord::Migration
	def change
		rename_column :likes, :guide_id, :story_id
	end
end
