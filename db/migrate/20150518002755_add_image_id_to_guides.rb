class AddImageIdToGuides < ActiveRecord::Migration
	def change
		add_column :guides, :image_id, :integer
	end
end
