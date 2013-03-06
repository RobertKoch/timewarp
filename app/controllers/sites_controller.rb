class SitesController < ApplicationController
  def index
  end

  def create
    if url = params[:site][:url]
      unless existing_entry = Site.find_by(url: url)
        # no record found, save and start crawler
      else
        # record found, link to archive
      end
    else
      @site = Site.new
      render 'home/index'
    end
  end
end
