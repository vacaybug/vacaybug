class Guide < ActiveRecord::Base
	attr_accessible :privacy, :country, :city, :region, :geonames_id, :user_id, :title, :description, :gn_data
	serialize :gn_data, JSON

	has_many :place_associations, :class_name => 'GuidePlaceAssociation'
    has_many :places, through: :place_associations

    has_many :likes

	belongs_to :user

	after_destroy :delete_associations
	before_save    :setup_params

    validates_length_of :description, maximum: 1000

	def delete_associations
		UserGuideAssociation.find_by_guide_id(self.id).destroy
		GuidePlaceAssociation.where(guide_id: self.id).destroy_all
	end

	def setup_params
		if self.title.nil?
			self.title = self.city + " trip"
		end
	end

	def likes_count
		self.likes.count
	end

	def as_json (options)
		super(methods: [:user, :likes_count])
	end
end
