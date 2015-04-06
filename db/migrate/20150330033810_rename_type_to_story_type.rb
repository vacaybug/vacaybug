class RenameTypeToStoryType < ActiveRecord::Migration
	def change
		rename_column :stories, :type, :story_type
	end
end
