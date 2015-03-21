class Rest::LikesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    # like or unlike depending on the current state
    def like_guide
        guide = Guide.find_by_id(params[:guide_id]) || not_found
        change = 0
        like = Like.where(guide_id: guide.id, user_id: current_user.id).first

        if like
            like.destroy
            change = -1
        else
            Like.create(user_id: current_user.id, guide_id: guide.id)
            change = 1
        end

        render json: {
            status: true,
            change: change
        }
    end
end
