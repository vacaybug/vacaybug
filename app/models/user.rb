class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :id, :email, :password, :password_confirmation, :remember_me
    attr_accessible :website, :location, :photo_url, :tag_line, :username, :first_name, :last_name
    attr_accessible :avatar, :birthday
      has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/assets/default_avatar.jpg"
      validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

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
    validate :validate_birthday

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

        options.merge!({methods: [:full_name]})

        json = super(options)
        json.merge!(additional_attributes(options)) if options[:additional]
        json.merge!({
            avatar: {
                thumb: self.avatar.url(:thumb),
                medium: self.avatar.url(:medium)
            }
        })

        json
    end

    private

    def validate_birthday
        if self.birthday.present? && self.birthday > Date.today
            errors.add(:birthday, "can't be in the future")
        end
    end
end
