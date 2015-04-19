class Rest::NewsfeedController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def stories
    	limit = 20
    	offset = params[:offset]
    	story_ids = current_user.newsfeed_stories.order('id desc').limit(limit)
    	if offset
    		story_ids = story_ids.where('id < ?', offset)
    	end

    	story_ids = story_ids.pluck(:story_id)
    	stories = story_ids.map do |story_id|
    		Story.find(story_id)
    	end

        render json: {
            models: stories.as_json(include_resource: true, user: current_user),
            next_offset: story_ids.last
        }
    end
end
