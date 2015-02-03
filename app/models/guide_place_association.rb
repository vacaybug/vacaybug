class GuidePlaceAssociation < ActiveRecord::Base
	attr_accessible :guide_id, :place_id, :order

	belongs_to :guide
	belongs_to :place
end
