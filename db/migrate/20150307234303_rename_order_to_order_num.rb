class RenameOrderToOrderNum < ActiveRecord::Migration
	def change
		rename_column :guide_place_associations, :order, :order_num
	end
end
