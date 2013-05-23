Timewarp::Application.routes.draw do

  root :to => 'home#index'
  get "home/index"

  #admin paths
  devise_for :admins, :path => "admin", :path_names => { :sign_in => 'login', :sign_out => 'logout'}, :controllers => {:sessions => "sessions" }
  resources :admins

  devise_scope :admin do
    get "admin" => "devise/sessions#new"
    get "admin/dashboard" => "admins#dashboard", :as => "admin_dashboard"
    get "admin/sites" => "admins#sites", :as => "admin_sites"
    get "admin/users" => "admins#index", :as => "admins"
  end

  #site paths and their relations
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
  post "sites/get_css_content" => "sites#get_css_content"

  #other paths
  get "team"           => "pages#about", :as => "team"
  get "history_of_web" => "pages#history_of_web", :as => "history"
  get "imprint"        => "pages#imprint", :as => "imprint"
end
