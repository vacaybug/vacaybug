class CreateNewsfeedAssociations < ActiveRecord::Migration
	def change
		create_table :newsfeed_associations do |t|
			t.integer :user_id
			t.integer :story_id

		    t.timestamps
		end

		add_index :newsfeed_associations, :user_id
		add_index :newsfeed_associations, :story_id
	end
end
