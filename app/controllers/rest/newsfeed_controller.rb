class Rest::NewsfeedController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def stories
        render json: {
            models: Story.all.as_json(include_resource: true)
        }
    end
end
