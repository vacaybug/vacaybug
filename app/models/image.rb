class Image < ActiveRecord::Base
    attr_accessible :image
    has_attached_file :image, :styles => { :large => "600x600>", :medium => "300x300>", :thumb => "100x100>" }
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

    def self.create_image_from_url (image_url)
        image = Image.create(image: URI.parse(image_url))
        image
    end

    def create_from_url
        render json: {
            model: self.create_image_from_url(params[:image_url])
        }
    end

    def as_json options={}
    	json = super(options)
    	json.merge({
    		image: {
    			large: self.image.url(:large),
    			medium: self.image.url(:medium),
    			thumb: self.image.url(:thumb)
    		}
    	})
    end
end
