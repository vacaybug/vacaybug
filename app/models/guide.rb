class Guide < ActiveRecord::Base
	attr_accessible :privacy, :country, :city, :region, :geonames_id, :user_id, :title, :description

	has_many :place_associations, :class_name => 'GuidePlaceAssociation', :dependent => :destroy
    has_many :places, through: :place_associations

	belongs_to :user

	after_destroy :delete_associations
	before_save    :setup_params

    validates_length_of :description, maximum: 1000

	def delete_associations
		UserGuideAssociation.find_by_guide_id(self.id).destroy
	end

	def setup_params
		if self.title.nil?
			self.title = self.city + " trip"
		end
	end
end
