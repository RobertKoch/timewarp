Timewarp::Application.routes.draw do

  root :to => 'home#index'
  get "home/index"

  resources :sites do 
    resources :comments, :only => [:create, :destroy] 
    member do
      post :create_comment
      get :increment_like
    end
  end
  
  resources :tags

  get "search" => "sites#search", :as => "search"
  get "tag_search" => "tags#search", :as => "tag_search"

  get "archive" => "sites#index", :as => "archive"
  get "sites/:id/analyse" => "sites#analyse", :as => "sites_analyse"
  get "sites/:id/timeline" => "sites#timeline", :as => "sites_timeline"
  put "sites/:id/publish" => "sites#publish", :as => "sites_publish"
  post "sites/rewrite_content" => "sites#rewrite_content"

  get "team"           => "pages#about", :as => "team"
  get "history_of_web" => "pages#history_of_web", :as => "history"
  get "imprint"        => "pages#imprint", :as => "imprint"
  get "agb"            => "pages#general_terms", :as => "terms"
end
