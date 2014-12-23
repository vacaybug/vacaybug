class Follower < ActiveRecord::Base
    attr_accessible :blocked, :follower_id, :user_id

    validates :follower_id, uniqueness: {scope: :user_id}
end
