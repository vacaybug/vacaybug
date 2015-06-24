class Internal::DashboardController < ActionController::Base
    include ApplicationHelper
    before_filter :check_logged_in
    before_filter :check_permission

    def check_permission
    	unless current_user.permission == User::PERMISSIONS::ADMIN
    		render text: 'Access Denied', status: 403
    	end
    end

    def users
    	@users = User.all

    	@grouped_cities = {}
    	guides = Guide.joins(:places).group('guide_id').having('count(*) >= 3 AND guide_type = 1').to_sql
    	('A'..'Z').each do |group|
    	    city_ids = City.where('cities.city LIKE ?', "#{group}%").select('gn_id, COUNT(g.geonames_id) as count').
    	        joins("join (#{guides}) g on g.geonames_id=cities.gn_id").group('cities.gn_id').order('count desc').
    	        map { |c| c.gn_id }
    	    @grouped_cities[group] = City.where(gn_id: city_ids).order('city asc')
    	end

    	render 'internal/dashboard/users'
    end
end
