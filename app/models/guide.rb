class Guide < ActiveRecord::Base
    attr_accessible :privacy, :country, :city, :region, :geonames_id, :user_id, :title, :description, :gn_data
    serialize :gn_data, JSON

    has_many :place_associations, :class_name => 'GuidePlaceAssociation'
    has_many :places, through: :place_associations

    belongs_to :user

    after_destroy :delete_associations
    before_save :setup_params
    after_create :create_story
    after_destroy :destroy_story

    validates_length_of :description, maximum: 1000

    def as_json (options={})
        options[:methods] ||= [:user, :story]
        super(options)
    end

    def story_attributes
        self.as_json(methods: [:user])
    end

    def story
        Story.where(resource_id: self.id, story_type: Story::TYPES::GUIDE).first
    end

    private

    def create_story
        Story.create({
            story_type: Story::TYPES::GUIDE,
            resource_id: self.id
        })
    end

    def destroy_story
        self.story.destroy
    end

    def setup_params
        if self.title.nil?
            self.title = self.city + " trip"
        end
    end

    def delete_associations
        UserGuideAssociation.find_by_guide_id(self.id).destroy
        GuidePlaceAssociation.where(guide_id: self.id).destroy_all
    end
end
