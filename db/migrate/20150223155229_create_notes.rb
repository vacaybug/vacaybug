class CreateNotes < ActiveRecord::Migration
	def change
		create_table :notes do |t|
			t.integer :user_id
			t.integer :place_id
			t.string  :note

		    t.timestamps
		end

		add_index :notes, :user_id
		add_index :notes, :place_id
	end
end
