class Rest::CommentsController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def index
        limit = 10

        story = Story.find(params[:story_id])
        total_count = story.comments.count
        comments = story.comments
        if params[:offset]
            comments = comments.where('id < ?', params[:offset])
        end
        comments = comments.order('id desc')

        has_more = comments.count > limit
        comments = comments.limit(limit).reverse
        if has_more
            next_offset = comments.first.id
        else
            next_offset = nil
        end

        render json: {
            models: comments,
            has_more: has_more,
            next_offset: next_offset,
            total_count: total_count
        }
    end

    def create
        story = Story.find_by_id(params[:story_id]) || not_found
        text = params[:text] || ""
        comment = story.comments.create(user_id: current_user.id, text: text)

        render json: {
            status: true,
            model: comment
        }
    end
end
