class City < ActiveRecord::Base
    attr_accessible :gn_data, :gn_id, :city, :region, :country
    serialize :gn_data, JSON

    def self.create_from_guide guide
        id = guide.gn_data["geonameId"]
        if City.where(gn_id: id).count == 0
            City.create(gn_id: id, gn_data: guide.gn_data, city: guide.city, region: guide.region, country: guide.country)
        end
    end
end
