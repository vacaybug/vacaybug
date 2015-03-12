class AddNoteToGuidePlaceAssociation < ActiveRecord::Migration
 	def change
 		add_column :guide_place_associations, :note, :text
 	end
end
