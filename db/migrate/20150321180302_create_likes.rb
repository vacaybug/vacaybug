class CreateLikes < ActiveRecord::Migration
	def change
		create_table :likes do |t|
			t.integer :guide_id
			t.integer :user_id

		    t.timestamps
		end

		add_index :likes, :guide_id
		add_index :likes, :user_id
		add_index :likes, [:guide_id, :user_id]
	end
end
