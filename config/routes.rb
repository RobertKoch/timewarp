Timewarp::Application.routes.draw do

  root :to => 'home#index'
  get "home/index"

  #admin paths
  devise_for :admins, :path => "admin", :path_names => { :sign_in => 'login', :sign_out => 'logout'}, :controllers => {:sessions => "sessions", :registrations => "registrations" }
  resources :admins

  devise_scope :admin do
    get "admin"                => "devise/sessions#new"
    get "admin/dashboard"      => "admins#dashboard", :as => "admin_dashboard"
    get "admin/sites"          => "admins#sites", :as => "admin_sites"
    get "admin/users"          => "admins#index", :as => "admins"
    get "admin/users/:id/edit" => "admins#edit", :as => "admin_edit"
    get "admin/elements"       => "elements#index", :as => "admin_elements"
  end

  #site paths and their relations
  resources :sites do 
    resources :comments, :only => [:index, :create, :destroy] 
    member do
      post :create_comment
      get :increment_like
    end
  end
  
  resources :tags
  resources :elements, :only => [:index, :destroy]

  get "search"     => "sites#search", :as => "search"
  get "tag_search" => "tags#search", :as => "tag_search"

  get "archive"                => "sites#index", :as => "archive"
  get "sites/:id/preview"      => "sites#preview", :as => "sites_preview" #only for admins
  get "sites/:id/analyse"      => "sites#analyse", :as => "sites_analyse"
  get "sites/:id/timeline"     => "sites#timeline", :as => "sites_timeline"
  put "sites/:id/publish"      => "sites#publish", :as => "sites_publish"
  post "sites/rewrite_content" => "sites#rewrite_content"
  post "sites/get_css_content" => "sites#get_css_content"

  #element paths
  get "/elements/teach"  => "elements#teach"
  post "/elements/learn" => "elements#learn"

  #other paths
  get "team"           => "pages#about", :as => "team"
  get "history_of_web" => "pages#history_of_web", :as => "history"
  get "imprint"        => "pages#imprint", :as => "imprint"
end
