module ApplicationHelper
    def check_logged_in
        unless user_signed_in?
            render text: 'Access Denied', status: 403
        end
    end

    def resource_name
        :user
    end
     
    def resource
        @resource ||= User.new
    end
     
    def devise_mapping
        @devise_mapping ||= Devise.mappings[:user]
    end

    def title(page_title)
        content_for(:title) { page_title }
    end

    def not_found
        raise ActionController::RoutingError.new('Not Found')
    end

    def render403
        render text: 'Method not allowed', status: 403
    end
end
