class Story < ActiveRecord::Base
    attr_accessible :story_type, :resource_id
    store :data, accessors: []

    has_many :likes
    has_many :comments

    module TYPES
        GUIDE = 1
        STATUS = 2
        SHARE = 3
    end

    def resource
        case self.story_type
        when TYPES::GUIDE
            Guide.find(resource_id)
        else
            nil
        end
    end

    def as_json(options={})
        puts options
        options[:except] = [:data]
        json = super(options)
        json.merge!({
            likes_count: self.likes.count,
            comments_count: self.comments.count,
            comments_preview: self.comments.order('id desc').slice(0, 10).reverse
        })
        if options[:include_resource]
            json.merge!(data: resource.story_attributes)
        end

        json
    end
end
