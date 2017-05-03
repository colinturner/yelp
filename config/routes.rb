Rails.application.routes.draw do
  get 'welcome/index'

  resources :restaurants do
    resources :reviews
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  root 'restaurants#index'



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
