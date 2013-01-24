# -*- encoding : utf-8 -*-
Timewarp::Application.routes.draw do
  root :to => 'home#index'
  get "home/index"
end
