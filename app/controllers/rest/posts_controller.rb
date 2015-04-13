class Rest::PostsController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def create
        post = Post.create(
            user_id: current_user.id,
            image_id: params[:image_id],
            raw_content: params[:raw_content]
        )

        render json: {
            model: post.as_json.merge(data: post.story.as_json({include_resource: true}))
        }
    end
end
