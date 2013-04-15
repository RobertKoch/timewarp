class CommentsController < ApplicationController
  def create
    @site = Site.find_by_token(params[:site][:token])
    @comment = @site.comments.build(params[:comment])

    if @comment.save
      redirect_to site_path(@site)
    else
      @tags = get_tags_with_weight @site
      render 'sites/show'
    end
  end

  def destroy
  end
end
