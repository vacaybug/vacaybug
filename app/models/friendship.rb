class FriendshipValidator < ActiveModel::Validator
    def validate(record)
        if User.find_by_id(record.user_id).nil?
            record.errors[:base] << "User with id #{record.user_id} is not found"
            return false
        end

        if User.find_by_id(record.friend_id).nil?
            record.errors[:base] << "User with id #{record.friend_id} is not found"
            return false
        end

        if record.status.nil?
            record.errors[:base] << "User with id #{record.user_id} is not found"
        end        
    end
end

class Friendship < ActiveRecord::Base
    module STATUS
        CONFIRMED = 2
        PENDING = 0
        REQUESTED = 1
    end

    attr_accessible :user_id, :friend_id, :status

    belongs_to :user
    belongs_to :friend, :class_name => "User"

    include ActiveModel::Validations
    validates_with FriendshipValidator

    def self.accept_request_single friend1_id, friend2_id
        f = Friendship.where(:user_id => friend1_id, :friend_id => friend2_id)
        f.status = STATUS::CONFIRMED
        f.save
    end

    def self.accept_request friend1_id, friend2_id
        self.transaction do
            self.accept_request_single(friend1_id, friend2_id)
            self.accept_request_single(friend2_id, friend1_id)
        end
    end

    def self.create_friendship_single friend1_id, friend2_id, status
        if Friendship.where(:user_id => friend1_id, :friend_id => friend2_id).count == 0
            Friendship.create(:user_id => friend1_id, :friend_id => friend2_id, :status => status)
            true
        else
            false
        end
    end

    def self.create_friendship friend1_id, friend2_id
        self.transaction do
            status1 = self.create_friendship_single(friend1_id, friend2_id, STATUS::REQUESTED)
            status2 = self.create_friendship_single(friend2_id, friend1_id, STATUS::PENDING)
            unless status1 && status2
                raise 'Could not create friendships'
            end
        end
    end

    def self.destroy_friendship friend1_id, friend2_id
        self.transaction do
            Friendship.where(:user_id => friend1_id, :friend_id => friend2_id).destroy_all
            Friendship.where(:user_id => friend2_id, :friend_id => friend1_id).destroy_all
        end
    end
end
