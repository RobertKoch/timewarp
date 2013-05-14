class SitesController < ApplicationController
  before_filter :site_exists_and_not_published, :only => [:analyse, :timeline]
  
  def index
    case @sort = params[:sort]
      when 'mostviewed'
        sort_term = 'visits DESC'
      when 'toprated'
        sort_term = 'likes DESC'
      else
        sort_term = 'created_at DESC'
    end

    @sites = Site.published.order_by("#{sort_term}").paginate(:page => params[:page], :per_page => 12)
    @tags = get_tags_with_weight
  end

  def show
    @site = Site.find_by_token(params[:id])
    if @site && @site.published?
      @site.update_attribute(:visits, @site.visits + 1)
      @tags = get_tags_with_weight @site
      @comment = @site.comments.build
    else
      redirect_to root_path
    end
  end

  def create
    url = params[:site][:url]
    @site = Site.new(:url => url)

    #todo: if entry already exist, redirect to archive
    unless existing_entry = Site.find_by(url: @site.url)
      if @site.save
        redirect_to sites_analyse_path(@site.token)
      else
        #only for debugging
        @sites = Site.all
        
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
  end

  def timeline
  end

  def publish
    @site = Site.find_by_token(params[:id])
    @site.title = params[:site][:title]
    @site.tags = params[:site][:tags].downcase
    @site.published = true

    if @site.update_attributes
      @site.take_snapshots
      
      redirect_to site_path(@site)
    else
      render 'sites/publish'
    end
  end

  def search 
    @term = params[:term]
    @sites_title = Site.published.where(title: /#{@term}/i)
    @sites_tags = Site.published.tagged_with(/#{@term}/i)
  end

  def create_comment
    @site = Site.find_by_token(params[:site][:token])
    @comment = @site.comments.build(params[:comment])


    if @comment.save
      @comments = @site.comments.reject {|c| !c.created_at}
      render :reload_comments
    else
      @tags = get_tags_with_weight @site
      render :create_comment
    end
  end

  def increment_like
    site = Site.find_by_token(params[:id])
    likes = site.likes + 1
    site.update_attribute :likes, likes

    respond_to do |format|
      format.json { render :json => likes.to_json }
    end
  end

  def rewrite_content
    file_path = Rails.root.join "public/saved_sites/#{params[:token]}/#{params[:version]}/index.html"

    file = File.open(file_path, "w")
    state = file.write(params[:content])
    file.close

    respond_to do |format|
      format.json { render :json => (state > 0) ? true : false}
    end
  end

private
  def site_exists_and_not_published
    if @site = Site.find_by_token(params[:id])
      redirect_to site_path(@site) if @site.published
    else
      redirect_to root_path
    end
  end
end
