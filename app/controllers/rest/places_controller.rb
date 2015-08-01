class Rest::PlacesController < ActionController::Base
    include ApplicationHelper
    include FsHelper

    before_filter :check_logged_in, except: [:index, :show]
    before_filter :check_guide_permission, only: [:create, :update, :destroy, :rearrange]

    def index
        guide = Guide.find_by_slug(params[:guide_id])
        models = []

        assocs = guide.place_associations.order('order_num ASC')
        assocs.each do |assoc|
            model = assoc.place.as_json(guide: guide, assoc_id: assoc.id)
            model["order_num"] = assoc.order_num
            model["assoc_id"] = assoc.id
            models << model
        end

        render json: {
            models: models
        }
    end

    def show
        guide = Guide.find(params[:guide_id])
        place = Place.find(params[:id])

        render json: {
            model: place.as_json(guide: guide)
        }
    end

    def create
        fs_data = params[:fs_data]
        guide = Guide.find(params[:guide_id])

        place = Place.find_by_fs_id(fs_data["id"])
        if !place # we don't have it in the DB, should create first
            # fetch photo
            photos = get_photos(fs_data["id"])
            fs_data["photos"] = photos

            place = Place.create({
                fs_data:  fs_data,
                fs_id:    fs_data["id"],
                title:    fs_data["name"],
                phone:    fs_data["contact"]["formattedPhone"],
                address:  fs_data["location"]["formattedAddress"].to_json,
                country:  fs_data["location"]["country"],
                city:     fs_data["location"]["city"],
                region:   fs_data["location"]["state"]
            })
            place.gen_yelp
        end

        guide.add_place(place)
        assoc = GuidePlaceAssociation.where(guide_id: guide.id).last

        render json: {
            model: place.as_json().merge({order_num: assoc.order_num, assoc_id: assoc.id})
        }
    end

    def update
        @place = Place.find(params[:id])
        allowed_fields = []
        changed = false

        allowed_fields.each do |field|
            if params.has_key?(field) and @user[field] != params[field]
                puts "sending #{field} #{params[field]}"
                changed = true
                @place.send("#{field}=", params[field])
            end
        end

        # editing note is little bit hacky :D
        gp = GuidePlaceAssociation.find(params[:assoc_id])
        if params[:note] != gp.note
            gp.note = params[:note]
            gp.save
        end

        if changed
            begin
                @place.save!
                render json: {
                    model: @place,
                    errors: @place.errors,
                    status: true
                }
            rescue ActiveRecord::RecordInvalid
                render json: {
                    model: @place,
                    errors: @place.errors,
                    status: false
                }
            end
        else
            render json: {
                model: @place,
                status: true
            }
        end
    end

    def rearrange
        new_order = params[:new_order]
        GuidePlaceAssociation.where(guide_id: params[:guide_id]).each do |assoc|
            if assoc.order_num != new_order[assoc.id.to_s]
                assoc.order_num = new_order[assoc.id.to_s]
                assoc.save
            end
        end

        render json: {}
    end

    def destroy
        @assoc = GuidePlaceAssociation.where(place_id: params[:id], guide_id: params[:guide_id]).first
        order = @assoc.order_num

        @assoc.destroy

        GuidePlaceAssociation.where(guide_id: params[:guide_id]).where('order_num > ?', order).each do |assoc|
            assoc.order_num = assoc.order_num - 1
            assoc.save
        end

        render json: {}
    end

    private

    def check_guide_permission
        guide = Guide.find_by_id(params[:guide_id])
        if current_user.id != guide.user_id
            render403
            return
        end
    end
end
