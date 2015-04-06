class CreateStories < ActiveRecord::Migration
    def change
        create_table :stories do |t|
            t.integer :type
            t.integer :resource_id
            t.text :data

            t.timestamps
        end

        add_index :stories, :resource_id
    end
end
