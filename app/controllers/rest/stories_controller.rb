class Rest::StoriesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in

    def like
        story = Story.find_by_id(params[:id]) || not_found
        change = 0
        like = Like.where(story_id: story.id, user_id: current_user.id).first

        if like
            like.destroy
            change = -1
        else
            Like.create(user_id: current_user.id, story_id: story.id)
            change = 1
        end

        if story.story_type == Story::TYPES::GUIDE
            story.resource.calculate_popularity
        end

        render json: {
            status: true,
            change: change
        }
    end

    def people_liked
        offset = params[:offset] || 0
        limit = 10

        story = Story.find(params[:id])
        likes = story.likes.where('id > ?', offset)
        has_more = likes.count > limit
        likes = likes.limit(limit)
        if has_more
            next_offset = likes.last.id
        else
            next_offset = nil
        end

        render json: {
            models: likes.map do |like|
                user = like.user.as_json({additional: true, current_user: current_user})
                user.merge({liked_date: like.created_at})
            end,
            has_more: has_more,
            next_offset: next_offset
        }
    end

    def destroy
        story = Story.find_by_id(params[:id]) || not_found
        if story.user_id == current_user.id
            # delete all newsfeed association
            NewsfeedAssociation.where(story_id: story.id).destroy_all

            if story.story_type == Story::TYPES::POST
                story.resource.destroy
                story.destroy
            end

            render json: {
                status: true
            }
        else
            render403
        end
    end
end
