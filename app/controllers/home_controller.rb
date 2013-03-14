class HomeController < ApplicationController
  def index
    @site = Site.new
    @sites = Site.all
  end
end
