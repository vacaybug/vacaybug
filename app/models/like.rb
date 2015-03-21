class Like < ActiveRecord::Base
	attr_accessible :user_id, :guide_id
	belongs_to :user
	belongs_to :guide
end
