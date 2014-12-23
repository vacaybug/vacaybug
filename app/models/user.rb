class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :trackable, :validatable

    # Setup accessible (or protected) attributes for your model
    attr_accessible :id, :email, :password, :password_confirmation, :remember_me
    attr_accessible :website, :location, :photo_url, :tag_line, :username, :first_name, :last_name
    attr_accessible :avatar
      has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
      validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

    has_many :followers, :class_name => 'Follower', :foreign_key => 'user_id'
    has_many :following, :class_name => 'Follower', :foreign_key => 'follower_id'

    validates :username, format: { with: /\A[a-zA-Z0-9]+\Z/ }
    validates :email, uniqueness: true
    validates :username, uniqueness: { case_sensitive: false }

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
        json = super(options.merge({methods: [:full_name]}))
        json.merge!(additional_attributes(options)) if options[:additional]

        json
    end
end
