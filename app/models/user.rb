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

    has_many :guide_associations, :class_name => 'UserGuideAssociation', :dependent => :destroy
    has_many :guides, through: :guide_associations

    validates :username,
        format: {
            with: /\A[a-zA-Z0-9_]+\Z/,
            message: 'should only contain letters, numbers and underscore character'
        },
        uniqueness: { case_sensitive: false },
        length: { in: 3..16 }
    validates :first_name,
        format: {
            with: /[a-zA-Z ]+/,
            message: 'can not contain numbers or special characters'
        },
        presence: true,
        length: { maximum: 100 }
    validates :last_name,
        format: {
            with: /[a-zA-Z ]+/,
            message: 'can not contain numbers or special characters'
        },
        presence: true,
        length: { maximum: 100 }
    validate :validate_birthday

    before_save :setup_names

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
    end

    def as_json(options = {})
        options[:except] ||= []
        options[:except] += [:created_at, :updated_at]

        unless options[:current_user] && options[:current_user].id == self.id
            options.merge!({except: [:email]})
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
            "/assets/default_avatar.jpg"
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
            user.username = "user#{rand.to_s[2..11]}"
            user.first_name = auth.info.first_name
            user.last_name = auth.info.last_name
            user.skip_confirmation!
        end
    end

    def self.from_omniauth_twitter(auth)
        where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.email = "user#{rand.to_s[2..11]}@twitter_generated_email.com"
            user.password = Devise.friendly_token[10,20]
            user.username = "user#{rand.to_s[2..11]}"
            user.first_name = auth.info.name
            user.image_id = Image.creatURI.parse(auth.info.image)
            user.skip_confirmation!
        end
    end

    def self.from_omniauth_google(auth)
        where(email: auth.info.email).first_or_create do |user|
            user.provider = auth.provider
            user.uid = auth.uid
            user.email = auth.info.email
            user.password = Devise.friendly_token[10,20]
            user.username = "user#{rand.to_s[2..11]}"
            user.first_name = auth.info.first_name
            user.last_name = auth.info.last_name
            user.avatar = URI.parse(auth.info.image)
            user.skip_confirmation!
        end
    end

    def self.create_username first, last
        first = first.split(" ").join("")
        last = last.split(" ").join("")
        username = first + last
        suffix = nil
        while User.where(username: username + suffix.to_s).count > 0 do
            if suffix.nil?
                suffix = 1
            else
                suffix += 1
            end
        end

        username + suffix.to_s
    end

    private

    def validate_birthday
        if self.birthday.present? && self.birthday > Date.today
            errors.add(:birthday, "can't be in the future")
        end
    end

    def setup_names
        self.first_name = self.first_name.split(" ").join(" ")
        self.last_name = self.last_name.split(" ").join(" ")
        self.username = self.username.downcase
    end
end
