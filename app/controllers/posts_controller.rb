class PostsController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    @post = Post.new
    @posts = timeline_posts
  end

  def create
    @post = Current.user.posts.new(post_params)
    if @post.save
      redirect_to root_path, notice: "投稿しました"
    else
      @posts = timeline_posts
      render :index, status: :unprocessable_content
    end
  end

  def destroy
    Current.user.posts.find(params[:id]).destroy!
    redirect_to root_path, notice: "削除しました"
  end

  private
    def post_params
      params.expect(post: [ :body ])
    end

    def timeline_posts
      Post.includes(:user).order(created_at: :desc)
    end
end
