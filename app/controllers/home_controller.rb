class HomeController < ActionController::Base
    before_filter :load_prefetch_data

    def index
        if current_user
            render 'backbone/dashboard'
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
end
