class AddFieldsToGuides < ActiveRecord::Migration
 	def change
 		add_column :guides, :user_id, :integer
 		add_column :guides, :title, :string
 		add_column :guides, :description, :text

 		add_index :guides, :user_id
 	end
end
