class Rest::GuidesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in
    before_filter :check_permission, only: [:delete, :update]

    def index
        user = User.find_by_username(params[:user_id]) || not_found
        guides = user.guides

        render json: {
            model: guides
        }
    end

    def create
    	guide = Guide.create(
    		country: params[:country],
    		region: params[:region],
    		city: params[:city],
    		geonames_id: params[:geonames_id],
            user_id: current_user.id
    	)

    	current_user.guide_associations.create(:guide_id => guide.id)

    	render json: {
    		model: guide
    	}
    end

    def show
        render json: {
            model: Guide.find(params[:id])
        }
    end

    def update
        guide = Guide.find(params[:id])
        if guide.user_id.to_i != current_user.id
            render text: 'Method not allowed', status: 403
            return
        end

        allowed_fields = [:privacy, :title, :description]
        changed = false

        allowed_fields.each do |field|
            if params.has_key?(field) and guide[field] != params[field]
                puts "sending #{field} #{params[field]}"
                changed = true
                guide.send("#{field}=", params[field])
            end
        end

        guide.save

        render json: {
            model: guide
        }
    end

    def delete
        guide = Guide.find(params[:id])
        guide.destroy
    end

    def check_permission
        guide = Guide.find(params[:id])
        if guide.user_id.to_i != current_user.id
            render403
        end
    end
end
