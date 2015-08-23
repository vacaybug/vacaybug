class AddFromToUsers < ActiveRecord::Migration
	def change
		add_column :users, :from, :string
	end
end
