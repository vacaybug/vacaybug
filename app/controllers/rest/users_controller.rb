class Rest::UsersController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in, only: [:follow, :unfollow]

    def show
        @user = find_user(params[:id])

        if @user
            render json: @user.as_json(additional: true, current_user: current_user)
        else
            render 'public/404.html', status: 404, layout: false
        end
    end

    def update
        @user = find_user(params[:id])

        if @user.id == current_user.id
            allowed_fields = [:username, :first_name, :last_name, :photo_url, :website, :location, :tag_line, :email, :birthday]
            changed = false

            allowed_fields.each do |field|
                puts field
                puts params[field]
                puts @user[field]
                if params.has_key?(field) and @user[field] != params[field]
                    puts "sending #{field} #{params[field]}"
                    changed = true
                    @user.send("#{field}=", params[field])
                end
            end

            if changed
                @user.save!
            end

            render json: {status: true}
        else
            render text: 'Method not allowed', status: 403
        end
    end

    def follow
        @user = find_user(params[:id])

        if Follower.where(user_id: @user.id, follower_id: current_user.id).count > 0
            render json: {
                status: false,
                message: 'Already following the user'
            }
        elsif @user.id == current_user.id
            render json: {
                status: false,
                message: 'You can not follow yourself'
            }
        else
            f = Follower.new(user_id: @user.id, follower_id: current_user.id)
            if f.save!
                render json: {
                    status: true
                }
            else
                render json: {
                    status: false,
                    message: 'An error occured. Please try again'
                }
            end
        end
    end

    def unfollow
        @user = find_user(params[:id])
        
        f = Follower.where(user_id: @user.id, follower_id: current_user.id).first
        if f
            f.destroy

            render json: {
                status: true
            }
        else
            render json: {
                status: false,
                message: 'You are not following the user'
            }
        end
    end

    private
    
    def find_user id
        if id.to_i.to_s == id.to_s # by id
            User.find_by_id(id)
        else
            User.find_by_username(id)
        end
    end
end
