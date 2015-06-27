class Rest::UsersController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in, except: [:show]

    def index
        page = (params[:page] || 1).to_i
        page_size = 30

        query = params[:query]

        users = User
        if query && query != ""
            users = users.where('username LIKE ? OR last_name LIKE ? OR first_name LIKE ?', "%#{query}%", "%#{query}%",  "%#{query}%")
        end
        sorted_users = users.select('users.id as id, COUNT(followers.user_id) AS count').joins("LEFT JOIN followers ON followers.user_id = users.id").group("users.id").order("count desc")
        sorted_users = sorted_users.slice((page - 1) * page_size, page_size)
        total_pages = (User.count + page_size - 1) / page_size

        render json: {
            models: sorted_users.map { |u| User.find(u.id) }.as_json(additional: true, current_user: current_user),
            total_pages: total_pages
        }
    end

    def show
        @user = find_user(params[:id])

        if @user
            render json: {
                model: @user.as_json(additional: true, current_user: current_user)
            }
        else
            render 'public/404.html', status: 404, layout: false
        end
    end

    def update
        @user = find_user(params[:id])

        if @user.id == current_user.id
            allowed_fields = [:username, :first_name, :last_name, :photo_url, :website, :location, :tag_line, :email, :birthday, :image_id]
            changed = false

            allowed_fields.each do |field|
                if params.has_key?(field) and @user[field] != params[field]
                    puts "sending #{field} #{params[field]}"
                    changed = true
                    @user.send("#{field}=", params[field])
                end
            end

            if changed
                begin
                    @user.save!
                    render json: {
                        model: @user,
                        errors: @user.errors,
                        status: true
                    }
                rescue ActiveRecord::RecordInvalid
                    render json: {
                        model: @user,
                        errors: @user.errors,
                        status: false
                    }
                end
            else
                render json: {
                    model: @user,
                    status: true
                }
            end
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
                Story.where(user_id: @user.id).where('created_at > ?', -15.days).order('id desc').limit(2).pluck(:id).each do |story_id|
                    NewsfeedAssociation.where(user_id: current_user.id, story_id: story_id).first_or_create
                end
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

    def followers
        @user = find_user(params[:id])
        @types = (params[:types] || "").split(",")
        # @offset = params[:offset] || 0
        @limit = 50

        list = []

        if @types.include?("followers")
            list += @user.followers.offset(@offset).limit(@limit).as_json(additional: true).map { |f| f.merge({type: "follower"}) }
        end
        if @types.include?("following")
            list += @user.following.offset(@offset).limit(@limit).as_json(additional: true).map { |f| f.merge({type: "following"}) }
        end
        if @types.include?("recommended")
            list += recommended.as_json(additional: true).map { |f| f.merge({type: "recommended"}) }
        end

        if current_user
            ids = Follower.where(:user_id => list.map { |f| f["id"] }, :follower_id => current_user.id).pluck(:user_id)
            list.map! do |f|
                f[:follows] = ids.include? (f["id"])
                f
            end
        end

        render json: {
            models: list,
            user: @user
        }
    end

    def upload_photo
        if current_user
            current_user.avatar = params[:file]
            current_user.save

            render json: {
                status: true,
                model: current_user
            }
        else
            render text: 'Method not allowed', status: 403
        end
    end

    private

    def recommended
        User.where(id: Follower.select('user_id, COUNT(*) followers_count').where('user_id != ?', current_user.id).group(:user_id).order('followers_count desc').limit(5).map { |s| s.user_id }).all
    end
end
