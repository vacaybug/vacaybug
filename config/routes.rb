Vacaybug::Application.routes.draw do
    devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_up => 'kcw', :sign_out => 'logout'}

    resources :friendships

    root :to => 'home#index'

    get 'static/profile'
    get 'static/guide'
    get 'static/follower'
    get 'static/following'
    get 'static/login'
    get 'static/signup'
    get 'static/message'
    get 'static/search'
    get 'static/searchresult'
    get 'static/home'
    get 'static/privacy'
    get 'static/about'
    get 'static/terms'
    get 'static/error'
    get 'static/guidepdf'
    get 'static/guide_static'
    get 'static/newsfeed'

    # restful api
    # MODELS ONLY
    namespace :rest do
        resources :users, only: [:show, :update] do
            collection do
                post :upload_photo
            end

            member do
                get :followers
                get :following
                # I apologize for this :'(
                get :guides

                put :follow
                put :unfollow
            end
        end

        resources :guides do
            resources :places do
            end
        end

        resources :posts, only: [:create] do
        end

        resources :stories, only: [:create, :delete] do
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

        match 'search' => 'search', via: :get
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
