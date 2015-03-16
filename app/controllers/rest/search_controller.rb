class Rest::SearchController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def search
        query = params[:query]

        render json: {
            models: Guide.all,
            query: query
        }
    end
end
