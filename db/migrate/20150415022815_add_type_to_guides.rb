class AddTypeToGuides < ActiveRecord::Migration
	def change
		add_column :guides, :guide_type, :integer
	end
end
