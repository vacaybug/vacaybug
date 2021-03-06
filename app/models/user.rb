include MailchimpHelper

class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :confirmable,  
        :recoverable, :rememberable, :trackable, :validatable,
        :omniauthable, :omniauth_providers => [:facebook, :twitter, :google_oauth2]


    # Setup accessible (or protected) attributes for your model
    attr_accessible :id, :email, :password, :password_confirmation, :remember_me, :unconfirmed_email,
        :image_id, :website, :location, :photo_url, :tag_line, :username, :first_name, :last_name, :birthday

    has_many :followers_relation, :class_name => 'Follower', :foreign_key => 'user_id'
    has_many :following_relation, :class_name => 'Follower', :foreign_key => 'follower_id'

    has_many :followers, through: :followers_relation, source: :follower
    has_many :following, through: :following_relation, source: :followee

    has_many :guide_associations, :class_name => 'UserGuideAssociation'
    has_many :guides, through: :guide_associations

    has_many :likes
    has_many :comments

    USERNAME_BLACKLIST = [
        "aboutus", "about", "terms", "tos", "story", "newsfeed", "assets", "rest", "messages", "share", "privacy",
        "home", "careers", "jobs", "support", "help", "contact", "blog", "guides", "stories", "guide", "search",
        "profile", "discover", "friends", "faq", "features", "login", "register", "auth", "password"
    ]

    module PERMISSIONS
        REGULAR = 0
        ADMIN = 1
    end

    validates :first_name,
        format: {
            with: /[a-zA-Z -]+$/,
            message: 'can not contain numbers or special characters'
        },
        presence: true,
        length: { maximum: 100 }
    validates :last_name,
        format: {
            with: /[a-zA-Z -]+$/,
            message: 'can not contain numbers or special characters'
        },
        presence: true,
        length: { maximum: 100 },
        if: "!provider"
    validates :username,
        format: {
            with: /\A[a-zA-Z0-9_]+\Z/,
            message: 'should only contain letters, numbers and underscore character'
        },
        exclusion: { in: User::USERNAME_BLACKLIST, message: "has already been taken" },
        uniqueness: { case_sensitive: false },
        length: { in: 3..30 }
    validate :validate_birthday

    before_validation :setup_names
    before_destroy :destroy_dependents
    after_create :subscribe_to_mailchimp

    def display_name
        self.first_name || self.username
    end

    def full_name
        name = self.first_name.to_s

        if self.last_name.to_s != ""
            name += " " if name.length > 0
            name += self.last_name
        end

        if name.length == 0
            name = self.username
        end

        name
    end

    def guides_count
        self.guides.where(guide_type: Guide::TYPES::PASSPORT).count
    end

    def visited_countries_count
        self.guides.where(guide_type: Guide::TYPES::PASSPORT).count('country', distinct: true)
    end

    def visited_cities_count
        self.guides.where(guide_type: Guide::TYPES::PASSPORT).count('geonames_id', distinct: true)
    end

    def additional_attributes (options={})
        data = {
            followers_count: self.followers.count,
            following_count: self.following.count
        }

        if options[:current_user]
            data.merge!({
                follows: Follower.where(:user_id => self.id, :follower_id => options[:current_user].id).count > 0
            })
        end
        data
    end

    def as_json(options = {})
        options[:except] ||= []
        options[:except] += [:created_at, :updated_at]

        unless options[:current_user] && options[:current_user].id == self.id
            options[:except] << :email
        end

        options.merge!({methods: [:full_name, :guides_count, :visited_cities_count, :visited_countries_count]})

        json = super(options)
        json.merge!(additional_attributes(options)) if options[:additional]
        json.merge!({
            avatar: {
                thumb: self.avatar(:thumb),
                medium: self.avatar(:medium)
            }
        })

        json
    end

    def avatar type
        if self.image_id
            Image.find(self.image_id).image.url(type)
        else
            ActionController::Base.helpers.asset_path("default_avatar.jpg")
        end
    end

    def newsfeed_stories
        NewsfeedAssociation.where(user_id: self.id)
    end

    def self.from_omniauth_facebook(auth)
        where(email: auth.info.email).first_or_create do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.email = auth.info.email
            user.password = Devise.friendly_token[10,20]
            user.first_name = auth.info.first_name
            user.last_name = auth.info.last_name
            user.username = "user#{rand.to_s[2..11]}"
            user.skip_confirmation!
        end
    end

    def self.from_omniauth_twitter(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.password = Devise.friendly_token[10,20]
            user.first_name = auth.info.name
            puts auth.info.image
            user.image_id = Image.create_image_from_url(auth.info.image.sub("_normal", "")).id
            user.username = "user#{rand.to_s[2..11]}"
            user.email = "#{user.username}@change_your_email.com"
            user.skip_confirmation!
        end
    end

    def self.from_omniauth_google(auth)
        where(email: auth.info.email).first_or_create do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.email = auth.info.email
            user.password = Devise.friendly_token[10,20]
            user.first_name = auth.info.first_name
            user.last_name = auth.info.last_name
            user.image_id = Image.create_image_from_url(auth.info.image.sub("sz=50", "")).id
            user.username = "user#{rand.to_s[2..11]}"
            user.skip_confirmation!
        end
    end

    def self.create_username first, last
        first = (first || "").split(/[ -]/).join("").downcase
        last = (last || "").split(/[ -]/).join("").downcase
        username = first + last
        suffix = nil

        username = username.slice(0, 28)
        while username.length < 3 do
            username += "0"
        end

        while User.where(username: username + suffix.to_s).count > 0 || User::USERNAME_BLACKLIST::include?(username + suffix.to_s) do
            if suffix.nil?
                suffix = 1
            else
                suffix += 1
            end
        end

        username + suffix.to_s
    end

    private

    def setup_names
        self.first_name = (self.first_name || "").split(" ").join(" ")
        self.last_name = (self.last_name || "").split(" ").join(" ")

        if self.username.nil?
            self.username = User.create_username(self.first_name, self.last_name)
        else
            self.username = self.username.downcase
        end
    end

    def validate_birthday
        if self.birthday.present? && self.birthday > Date.today
            errors.add(:birthday, "can't be in the future")
        end
    end

    def destroy_dependents
        self.likes.destroy_all
        self.comments.destroy_all
        self.guides.destroy_all
    end

    def subscribe_to_mailchimp
        subscribe self.email if self.email.present?
    end
end
