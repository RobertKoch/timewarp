class AdminsController < ApplicationController
  before_filter :authenticate_admin!

  def index
    @admins = Admin.all
  end

  def show
    @admin = Admin.find(params[:id])
  end

  def edit
    @resource = Admin.find(params[:id])
    render 'devise/registrations/edit'
  end

  def dashboard
    @sites = Site.all
    @tags = Site.tags_with_weight
    @sysinfo = SysInfo.new
    @pageviews = 0

    @sites.each { |site| @pageviews += site.visits }
  end

  def sites 
    @published = Site.published.order_by("created_at DESC").paginate(:page => params[:published_page], :per_page => 10)
    @unpublished = Site.unpublished.order_by("created_at DESC").paginate(:page => params[:unpublished_page], :per_page => 10)
  end
end
