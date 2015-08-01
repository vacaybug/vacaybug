class Guide < ActiveRecord::Base
    attr_accessible :privacy, :country, :city, :region, :geonames_id, :user_id, :title, :description, :gn_data, :guide_type, :slug
    serialize :gn_data, JSON

    has_many :place_associations, :class_name => 'GuidePlaceAssociation'
    has_many :places, through: :place_associations

    belongs_to :user

    after_destroy :delete_associations
    before_save :setup_params
    after_create :create_story
    after_create :create_city
    after_destroy :destroy_story

    validates_length_of :description, maximum: 1000

    module TYPES
        PASSPORT = 1
        WISHLIST = 2
    end

    validates :guide_type, :inclusion => {:in => [TYPES::PASSPORT, TYPES::WISHLIST]}

    def as_json (options={})
        options[:methods] ||= [:user, :story]
        json = super(options)
        json.merge!({
            image: {
                large: self.avatar(:large),
                thumb: self.avatar(:thumb),
                medium: self.avatar(:medium)
            }
        })
    end

    def story_attributes
        self.as_json(methods: [:user])
    end

    def story
        Story.where(resource_id: self.id, story_type: Story::TYPES::GUIDE).first
    end

    def add_place place
        order = self.place_associations.count + 1

        assoc = self.place_associations.create(
            place_id: place.id,
            order_num: order
        )
        order
    end

    def calculate_popularity
        score = (self.story.likes.count + self.story.comments.count)
        self.popularity = score
        self.save
    end

    def can_publish
        self.guide_type == Guide::TYPES::PASSPORT
    end

    def avatar type
        if self.image_id
            Image.find(self.image_id).image.url(type)
        else
            "/assets/default_guide.png"
        end
    end

    def generate_slug
        guide_slug = self.city
        guide_slug += "_" + self.region if self.region.present?
        suffix = ""
        count = 1

        while Guide.where("slug = ? AND id != ?", "#{guide_slug}#{suffix}", self.id).count > 0 do
            suffix = "_" + count.to_s
            count += 1
        end

        "#{guide_slug}#{suffix}"
    end

    private

    def create_story
        Story.create({
            user_id: self.user_id,
            story_type: Story::TYPES::GUIDE,
            resource_id: self.id
        })
    end

    def create_city
        City.create_from_guide(self)
    end

    def destroy_story
        begin
            self.story.destroy
        rescue
        end
    end

    def setup_params
        if self.title.nil?
            self.title = self.city + " Guide"
        end

        if self.slug.nil?
            self.slug = self.generate_slug
        end
    end

    def delete_associations
        begin
            UserGuideAssociation.find_by_guide_id(self.id).destroy
        rescue
        end
        GuidePlaceAssociation.where(guide_id: self.id).destroy_all
    end
end
