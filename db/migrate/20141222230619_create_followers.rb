class CreateFollowers < ActiveRecord::Migration
    def change
        create_table :followers do |t|
            t.integer :user_id
            t.integer :follower_id
            t.boolean :blocked

            t.timestamps
        end

        add_index :followers, :user_id
        add_index :followers, :follower_id
        add_index :followers, [:follower_id, :user_id], unique: true
    end
end
