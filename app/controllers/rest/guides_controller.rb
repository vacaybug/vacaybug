class Rest::GuidesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in
    before_filter :check_permission, only: [:destroy, :update]

    def index
        @user = find_user(params[:user_id])
        if params[:type] == 'wishlist'
            if @user.id != current_user.id
                render403
                return
            end
            @type = Guide::TYPES::WISHLIST
        elsif params[:type] == 'passport'
            @type = Guide::TYPES::PASSPORT
        else
            not_found
        end

        render json: {
            models: @user.guides.where(guide_type: @type).order('id desc')
        }
    end

    def create
        if params[:guide_type] == 'passport'
            guide_type = Guide::TYPES::PASSPORT
        elsif params[:guide_type] == 'wishlist'
            guide_type = Guide::TYPES::WISHLIST
        else
            guide_type = nil
        end

    	guide = Guide.create(
            description: params[:description],
    		country: params[:country],
    		region: params[:region],
    		city: params[:city],
    		geonames_id: params[:geonames_id],
            user_id: current_user.id,
            gn_data: params[:gn_data],
            guide_type: guide_type
    	)

    	current_user.guide_associations.create(:guide_id => guide.id)

    	render json: {
    		model: guide
    	}
    end

    def show
        render json: {
            model: Guide.find(params[:id]).as_json
        }
    end

    def update
        allowed_fields = [:title, :description, :guide_type]
        changed = false

        allowed_fields.each do |field|
            if params.has_key?(field) and @guide[field] != params[field]
                puts "sending #{field} #{params[field]}"
                changed = true
                @guide.send("#{field}=", params[field])
            end
        end

        @guide.save

        render json: {
            model: @guide
        }
    end

    def destroy
        @guide.destroy

        render json: {
        }
    end

    def duplicate
        @guide = Guide.find(params[:id])

        if @guide.user_id != current_user.id # user can't copy his/her own guide
            # TODO: maybe move it to guide.rb
            copy_guide = Guide.create(
                description: @guide.description,
                country: @guide.country,
                region: @guide.region,
                city: @guide.city,
                geonames_id: @guide.geonames_id,
                user_id: current_user.id,
                gn_data: @guide.gn_data,
                guide_type: Guide::TYPES::WISHLIST
            )
            current_user.guide_associations.create(:guide_id => copy_guide.id)

            @guide.places.each do |place|
                copy_guide.add_place(place)
            end
        end

        render json: {
        }
    end

    private

    def check_permission
        @guide = Guide.find(params[:id])
        if @guide.user_id.to_i != current_user.id
            render403
        end
    end
end
