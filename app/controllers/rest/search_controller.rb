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

    def most_commented
        ids = Story.select('stories.id, COUNT(*) AS comments_count').where(story_type: Story::TYPES::GUIDE).joins(:comments).group('stories.id').order('comments_count desc').limit(5).pluck(:id)
        Story.where(id: ids).map { |s| s.resource }
    end

    def most_liked
        ids = Story.select('stories.id, COUNT(*) AS likes_count').where(story_type: Story::TYPES::GUIDE).joins(:likes).group('stories.id').order('likes_count desc').limit(5).pluck(:id)
        Story.where(id: ids).map { |s| s.resource }
    end

    def famous
        render json: {
            most_commented: most_commented,
            most_liked: most_liked
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
