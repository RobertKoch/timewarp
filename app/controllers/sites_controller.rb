class SitesController < ApplicationController
  def index
    @sites = Site.published
    #todo: outsource the following code in a function or module and replace dummy-links
    taglist = Site.tags_with_weight
    @tags = []
    taglist.each do |t|
      @tags << {text: t[0], weight: t[1], link: '#'}
    end
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

  def timeline
    if @site = Site.find_by_token(params[:id])
    else
      redirect_to root_path
    end   
  end

  def publish
    @site = Site.find_by_token(params[:id])
    @site.title = params[:site][:title]
    @site.tags = params[:site][:tags]

    if @site.update_attributes
      redirect_to site_path(@site)
    else
      render 'sites/publish'
    end
  end
end
