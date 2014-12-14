class AddFieldsToUsers < ActiveRecord::Migration
    def change
        add_column :users, :first_name, :string
        add_column :users, :last_name, :string
        add_column :users, :website, :string
        add_column :users, :location, :string
        add_column :users, :photo_url, :string
        add_column :users, :tag_line, :text
    end
end
