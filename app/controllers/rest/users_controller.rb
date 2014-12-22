class Rest::UsersController < ActionController::Base
    def show
        @user = find_user(params[:id])

        if @user
            render json: @user
        else
            render 'public/404.html', status: 404, layout: false
        end
    end

    def update
        @user = find_user(params[:id])

        if @user.id == current_user.id
            allowed_fields = [:username, :first_name, :last_name, :photo_url, :website, :location, :tag_line]
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

            render json: 'OK'
        else
            render text: 'Method not allowed', status: 403
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
