Rails.application.routes.draw do
  # mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  get 'welcome/index'
  # get 'sign_out' => 'welcome#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get '/administrivia', :to => redirect('/templates/privacy_policy.html')

  resources :users
  resources :events
  resources :ratings
  resources :attendrequests
  resources :starchess_games

end
