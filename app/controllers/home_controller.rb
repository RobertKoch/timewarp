class HomeController < ApplicationController
  def index
    @site = Site.new
  end
end
