class AddPermissionToUsers < ActiveRecord::Migration
	def change
		add_column :users, :permission, :integer, default: 0
	end
end
