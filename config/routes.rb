Travelrank::Application.routes.draw do
    devise_for :users
    match '/users/sign_out(.:format)' => 'devise/sessions#destroy', via: :get

    resources :friendships
    resources :users

    root :to => 'home#index'

    match '(*all)' => 'home#backbone', via: :get
end
