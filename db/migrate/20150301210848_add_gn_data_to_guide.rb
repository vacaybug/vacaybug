class AddGnDataToGuide < ActiveRecord::Migration
	def change
		add_column :guides, :gn_data, :text
	end
end
