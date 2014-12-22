Vacaybug::Application.routes.draw do
    devise_for :users

    resources :friendships

    root :to => 'home#index'

    get 'static/guide'
    get 'static/follower'
    get 'static/following'
    get 'static/login'

    namespace :rest do
        resources :users, only: [:show, :update] do
        end
    end

    match '(*all)' => 'home#backbone', via: :get
end
