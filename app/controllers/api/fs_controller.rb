class Api::FsController < ActionController::Base
    include ApplicationHelper
    include FsHelper

    def search_places
        query = params[:query]
        near_location = params[:near_location]
        result = search(near_location, query)

    	render json: result
    end
end
