Vacaybug::Application.routes.draw do
    devise_for :users, :path => '',
        :path_names => {:sign_in => 'login', :sign_up => 'signup', :sign_out => 'logout'},
        :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}

    resources :friendships

    root :to => 'home#index'

    get 'static/profile'
    get 'static/guide'
    get 'static/follower'
    get 'static/following'
    get 'static/login'
    get 'static/signup'
    get 'static/message'
    get 'static/discover'
    get 'static/search'
    get 'static/home'
    get 'static/privacy'
    get 'static/about'
    get 'static/terms'
    get 'static/error'
    get 'static/guidepdf'
    get 'static/guide_static'
    get 'static/newsfeed'
    get 'static/confirmation'
    get 'static/password'
    get 'static/beta'
    get 'static/like'
    get 'static/comment'
    get 'static/follow'
    get 'static/landing'
    get 'static/mapview'
    get 'static/design'

    # restful api
    # MODELS ONLY
    namespace :rest do
        resources :users, only: [:show, :update, :index] do
            resources :guides, only: [:index] do
            end

            collection do
                post :upload_photo
            end

            member do
                get :followers

                put :follow
                put :unfollow
            end
        end

        resources :guides do
            member do
                post :duplicate
            end

            resources :places do
                collection do
                    post :rearrange
                end
            end
        end

        resources :posts, only: [:create] do
        end

        resources :stories, only: [:create, :destroy] do
            resources :comments, only: [:index, :create] do
            end

            member do
                get :people_liked
                put :like

                put :add_comment
            end
        end

        resources :images do
            collection do
                post :create_from_url
            end
        end

        resources :newsfeed do
            collection do
                get :stories
            end
        end

        namespace :search do
            get :famous
            get :search
        end

        namespace :cities do
            get :discover
        end
    end

    namespace :internal do
        namespace :dashboard do
            get :users
        end
    end

    # all apis will go here
    namespace :api do
        # four square apis
        namespace :fs do
            get :search_places
        end
    end

    match 'about' => 'home#about', via: :get
    match 'privacy' => 'home#privacy', via: :get
    match 'terms' => 'home#terms', via: :get
    match '(*all)' => 'home#backbone', via: :get
end
