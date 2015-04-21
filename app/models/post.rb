class Post < ActiveRecord::Base
    require 'rails_rinku'

    attr_accessible :image_id, :user_id, :content, :raw_content

    belongs_to :user

    after_create   :create_story
    before_destroy :destroy_story
    before_save    :process_content

    def image
        if self.image_id
            im = Image.find(self.image_id)
            {
                large: im.image.url(:large),
                medium: im.image.url(:medium),
                thumb: im.image.url(:thumb)
            }
        else
            nil
        end
    end

    def story_attributes
        self.as_json(methods: [:image, :user])
    end

    def story
        Story.where(resource_id: self.id, story_type: Story::TYPES::POST).first
    end

    def can_publish
        true
    end

    private

    def destroy_story
        self.story.destroy
    end

    def process_content
        if !self.raw_content.nil?
            self.content = Rinku.auto_link self.raw_content
        end
    end

    def create_story
        Story.create({
            user_id: self.user_id,
            story_type: Story::TYPES::POST,
            resource_id: self.id
        })
    end
end
