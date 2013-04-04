class TagsController < ApplicationController
  def index
  end

  def show
  end

  def search
    term = params[:term]
    @taglist = Site.tags.find_all { |tag| /#{term}/ =~ tag }
    respond_to do |format|
      format.json { render :json => @taglist.to_json }
    end
  end
end
