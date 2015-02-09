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

    namespace :rest do
        resources :users, only: [:show, :update] do
            collection do
                post :upload_photo
            end

            member do
                get :followers
                get :following
                put :follow
                put :unfollow
            end
        end
    end

    match 'privacy' => 'home#privacy', via: :get
    match '(*all)' => 'home#backbone', via: :get
end
