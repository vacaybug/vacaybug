module ApplicationHelper
    def check_logged_in
        unless user_signed_in?
            render text: 'Access Denied', status: 403
        end
    end
end
