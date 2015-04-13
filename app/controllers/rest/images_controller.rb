class Rest::ImagesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def create_from_url
        image = Image.create(image: URI.parse(params[:image_url]))
        render json: {
            model: image
        }
    end

    def create
        image = Image.create(image: params[:file])
        render json: {
            model: image
        }
    end
end
