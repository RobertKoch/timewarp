class SitesController < ApplicationController
  def index
    @sites = Site.published
  end

  def show
    @site = Site.find_by_token(params[:id])
  end

  def create
    url = params[:site][:url]
    @site = Site.new(:url => url)

    #todo: if entry already exist, redirect to archive
    unless existing_entry = Site.find_by(url: @site.url)
      if @site.save
        redirect_to sites_analyse_path(@site.token)
      else
        render 'home/index'
      end
    else
      redirect_to site_path(existing_entry.token)
    end
  end

  def destroy
    site = Site.find_by_token(params[:id])
    if site.destroy
      redirect_to root_path
    end
  end

  def analyse
    if @site = Site.find_by_token(params[:id])
    else
      redirect_to root_path
    end
  end
end
