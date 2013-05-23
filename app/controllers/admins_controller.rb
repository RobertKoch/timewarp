class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
  end

  def dashboard
    @admins = Admin.all 
  end

  def sites 
    @published = Site.published.paginate(:page => params[:published_page], :per_page => 10)
    @unpublished = Site.unpublished.paginate(:page => params[:unpublished_page], :per_page => 10)
  end
end
