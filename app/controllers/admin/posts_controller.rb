class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    scope = Post.order(published_at: :desc, created_at: :desc)
    scope = scope.where(locale: params[:locale]) if params[:locale].present?

    if params[:q].present?
      scope = scope.where("title ILIKE :q OR excerpt ILIKE :q OR tags ILIKE :q", q: "%#{params[:q]}%")
    end

    @posts = scope.with_attached_featured_image.limit(100)
  end

  def show; end

  def new
    @post = Post.new(locale: "en", published_at: Time.current,
                     author_name: "SystemOrEcosystem", reading_minutes: 3)
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      redirect_to admin_post_path(@post), notice: "Post saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.with_attached_featured_image.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit(
      :title, :excerpt, :locale, :published_at, :reading_minutes,
      :author_name, :tag_list, :position, :body, :featured_image
    )
  end
end
