class Rest::PlacesController < ActionController::Base
    include ApplicationHelper
    include FsHelper

    before_filter :check_logged_in
    before_filter :check_guide_permission, only: [:create, :update, :delete]

    def index
        guide = Guide.find(params[:guide_id])

        # assocs = guide.place_associations

        render json: {
            models: guide.places
        }
    end

    def show
        place = Place.find(params[:place_id])
        render json: {
            model: place
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
        end

        # order = guide.place_associations.count + 1

        assoc = guide.place_associations.create(
            place_id: place.id
            # order: order
        )

        render json: {
            model: place
        }
    end

    def update
    end

    def delete
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
