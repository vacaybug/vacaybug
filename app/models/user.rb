class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :email, :password, :password_confirmation, :remember_me
    attr_accessible :website, :location, :photo_url, :tag_line

    has_many :friendships
    has_many :friends, :through => :friendships, :conditions => "status = 2"

    def add_friend friend_id
        Friendship.create_friendship(self.id, friend_id)
    end

    def remove_friend friend_id
        Friendship.destroy_friendship(self.id, friend_id)
    end
end
