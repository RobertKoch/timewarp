Timewarp::Application.routes.draw do

  root :to => 'home#index'
  get "home/index"

  resources :sites, :only => [:index, :show, :create]

  get "archive"   => "sites#index", :as => "archive"

  get "team"      => "pages#about"
  get "impressum" => "pages#imprint"
  get "agb"       => "pages#general_terms"
end
