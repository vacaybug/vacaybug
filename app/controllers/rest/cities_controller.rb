class Rest::CitiesController < ActionController::Base
    include ApplicationHelper
    before_filter :check_logged_in

    def discover
        response = {}
        guides = Guide.joins(:places).group('guide_id').having('count(*) >= 3').to_sql
        ('A'..'Z').each do |group|
            city_ids = City.where('cities.city LIKE ?', "#{group}%").select('gn_id, COUNT(g.geonames_id) as count').
                joins("join (#{guides}) g on g.geonames_id=cities.gn_id").group('cities.gn_id').order('count desc').limit(7).
                map { |c| c.gn_id }
            response[group] = City.where(gn_id: city_ids).order('city asc')
        end
        render json: response
    end
end
