class CommentsController < ApplicationController
  before_filter :authenticate_admin!
  def index
    @site = Site.find_by_token(params[:site_id])
  end

  def destroy
    site = Site.find_by_token(params[:site_id])
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_to site_comments_path(site)
  end
end
