Timewarp::Application.routes.draw do

  root :to => 'home#index'
  get "home/index"

  resources :sites, :only => [:index, :show, :create, :destroy]

  get "archive" => "sites#index", :as => "archive"
  get "sites/:id/analyse" => "sites#analyse", :as => "sites_analyse"

  get "team"           => "pages#about", :as => "team"
  get "history_of_web" => "pages#history_of_web", :as => "history"
  get "imprint"        => "pages#imprint", :as => "imprint"
  get "agb"            => "pages#general_terms", :as => "terms"
end
