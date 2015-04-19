class Rest::SearchController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def search_recent geonames_id
    	render json: {
            models: Guide.where(geonames_id: geonames_id).order('id desc').limit(50)
        }
    end

    def search_popular geonames_id
    	render json: {
    		models: Guide.where(geonames_id: geonames_id).order('popularity desc').limit(50)
    	}
    end

    def search
        query = params[:query]
        geonames_id = params[:id]
        key = params[:key]

        if key == 'popular'
        	search_popular(geonames_id)
        elsif key == 'recent'
        	search_recent(geonames_id)
        else
        	render json: {
        		models: []
        	}
        end
    end
end
