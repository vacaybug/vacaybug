class Follower < ActiveRecord::Base
		belongs_to :follower, class_name: "User", foreign_key: 'follower_id'
		belongs_to :followee, class_name: "User", foreign_key: 'user_id'

    attr_accessible :blocked, :follower_id, :user_id

    validates :follower_id, uniqueness: {scope: :user_id}
end
