class TagsController < ApplicationController
  def index
    @taglist = Site.tags_with_weight
  end

  def show
    @tag = params[:id]
    @sites = Site.published.tagged_with @tag
  end

  def search
    term = params[:term]
    @taglist = Site.tags.find_all { |tag| /#{term}/i =~ tag }
    respond_to do |format|
      format.json { render :json => @taglist.to_json }
    end
  end
end
