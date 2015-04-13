class CreatePosts < ActiveRecord::Migration
    def change
        create_table :posts do |t|
            t.integer    :image_id
            t.text       :raw_content
            t.text       :content

            t.timestamps
        end
    end
end
