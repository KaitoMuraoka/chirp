class LikesController < ApplicationController
  def create
    Post.find(params[:post_id]).likes.find_or_create_by(user: Current.user)
    redirect_to root_path
  end

  def destroy
    Current.user.likes.where(post_id: params[:post_id]).destroy_all
    redirect_to root_path
  end
end
