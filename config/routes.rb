Timewarp::Application.routes.draw do
  get "sites/index"

  get "sites/new"

  get "sites/create"

  root :to => 'home#index'
  get "home/index"

  get "team"         => "pages#about"
  get "impressum"       => "pages#imprint"
  get "agb" => "pages#general_terms"
end
