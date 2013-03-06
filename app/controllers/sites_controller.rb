class SitesController < ApplicationController
  def index
  end

  def create
    url = params[:site][:url]
    @site = Site.new(:url => url)

    #todo: if entry already exist, redirect to archive
    #unless existing_entry = Site.find_by(url: url)

    if @site.save
      #start crawler and do something
    else
      render 'home/index'
    end
  end
end
