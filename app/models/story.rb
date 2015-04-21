include NewsfeedHelper

class Story < ActiveRecord::Base
    attr_accessible :story_type, :resource_id, :user_id
    store :data, accessors: []

    belongs_to :user

    has_many :likes
    has_many :comments

    after_create :publish_to_followers

    module TYPES
        GUIDE = 1
        POST = 2
        SHARE = 3
    end

    def resource
        case self.story_type
        when TYPES::GUIDE
            Guide.find(resource_id)
        when TYPES::POST
            Post.find(resource_id)
        else
            nil
        end
    end

    def is_liked_by user
        user && self.likes.where(user_id: user.id).count > 0
    end

    def as_json(options={})
        options[:except] = [:data]
        json = super(options)
        json.merge!({
            liked: self.is_liked_by(options[:user]),
            likes_count: self.likes.count,
            comments_count: self.comments.count,
            comments_preview: self.comments.order('id desc').slice(0, 10).reverse
        })
        if options[:include_resource]
            json.merge!(data: resource.story_attributes)
        end

        json
    end

    def publish_to_followers
        if resource.can_publish
            story_published self
        end
    end
end
