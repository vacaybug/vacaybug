class UserGuideAssociation < ActiveRecord::Migration
	def change
		create_table :user_guide_associations do |t|
		    t.integer :user_id
		    t.integer :guide_id
		end

		add_index :user_guide_associations, :user_id
		add_index :user_guide_associations, :guide_id
	end
end
