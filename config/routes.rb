Vacaybug::Application.routes.draw do
    devise_for :users, :path => '', :path_names => {:sign_in => 'login', :sign_up => 'register', :sign_out => 'logout'}

    resources :friendships

    root :to => 'home#index'

    get 'static/guide'
    get 'static/follower'
    get 'static/following'
    get 'static/login'
    get 'static/signup'
    get 'static/message'
    get 'static/search'
    get 'static/home'

    namespace :rest do
        resources :users, only: [:show, :update] do
            member do
                get :followers
                get :following
                put :follow
                put :unfollow
            end
        end
    end

    match '(*all)' => 'home#backbone', via: :get
end
