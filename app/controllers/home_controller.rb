class HomeController < ActionController::Base
    def index
        render 'home/index'
    end

    def backbone
        render 'backbone/dashboard'
    end
end
