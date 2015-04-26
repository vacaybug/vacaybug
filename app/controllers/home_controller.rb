class HomeController < ActionController::Base
    before_filter :load_prefetch_data

    def index
        if current_user
            redirect_to "/#{current_user.username}"
        else
            render 'home/landing'
        end
    end

    def load_prefetch_data
        @prefetch_data = {}
        @prefetch_data[:current_user] = current_user
    end

    def backbone
        render 'backbone/dashboard'
    end

    def privacy
        render 'home/privacy'
    end
end
