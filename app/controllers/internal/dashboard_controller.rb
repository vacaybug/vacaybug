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
    	@groups = User.select(
    		'date(created_at) date, GROUP_CONCAT(id) as ids'
    	).group('date(created_at)').map { |u| [u.date, u.ids] }

    	render 'internal/dashboard/users'
    end
end
