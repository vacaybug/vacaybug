class Rest::GuidesController < ActionController::Base
    include ApplicationHelper

    before_filter :check_logged_in, except: [:index, :show]
    before_filter :check_permission, only: [:destroy, :update]

    def index
        @user = find_user(params[:user_id])
        if params[:type] == 'wishlist'
            if !current_user || @user.id != current_user.id
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
        guide = Guide.find_by_slug(params[:id])
        if guide.guide_type == Guide::TYPES::WISHLIST && (!current_user || current_user.id != guide.user_id)
            render403
        else
            render json: {
                model: guide.as_json
            }
        end
    end

    def update
        allowed_fields = [:title, :description, :guide_type, :image_id]
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
