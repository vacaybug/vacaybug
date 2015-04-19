class NewsfeedAssociation < ActiveRecord::Base
	attr_accessible :user_id, :story_id

	belongs_to :user
	belongs_to :story
end
