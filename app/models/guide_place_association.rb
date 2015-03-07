class GuidePlaceAssociation < ActiveRecord::Base
	attr_accessible :guide_id, :place_id, :order_num

	belongs_to :guide
	belongs_to :place
end
