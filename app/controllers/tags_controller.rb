class TagsController < ApplicationController
  def index
    @taglist = Site.tags_with_weight
  end

  def show
    @tag = params[:id]
    
    @sites = Site.published.tagged_with @tag
    @sites = @sites.order_by('created_at DESC').paginate(:page => params[:page], :per_page => 12)
  end

  def search
    term = params[:term]
    @taglist = Site.tags.find_all { |tag| /#{term}/i =~ tag }
    respond_to do |format|
      format.json { render :json => @taglist.to_json }
    end
  end
end
