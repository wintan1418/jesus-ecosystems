class Admin::EpisodesController < Admin::BaseController
  before_action :set_episode, only: [:show, :edit, :update, :destroy]

  def index
    scope = Episode.order(season: :desc, number: :desc, published_at: :desc)
    scope = scope.where(locale: params[:locale]) if params[:locale].present?
    if params[:q].present?
      scope = scope.where("title ILIKE :q OR description ILIKE :q", q: "%#{params[:q]}%")
    end
    @episodes = scope.with_attached_audio_file
                     .with_attached_cover_image
                     .limit(100)
  end

  def show; end

  def new
    @episode = Episode.new(
      locale: "en",
      season: 1,
      number: (Episode.maximum(:number) || 0) + 1,
      published_at: Time.current
    )
  end

  def create
    @episode = Episode.new(episode_params)
    if @episode.save
      redirect_to admin_episode_path(@episode), notice: "Episode saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @episode.update(episode_params)
      redirect_to admin_episode_path(@episode), notice: "Episode updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @episode.destroy
    redirect_to admin_episodes_path, notice: "Episode deleted."
  end

  private

  def set_episode
    @episode = Episode.with_attached_audio_file.with_attached_cover_image.friendly.find(params[:id])
  end

  def episode_params
    params.require(:episode).permit(
      :title, :description, :locale, :season, :number,
      :duration_seconds, :published_at, :explicit, :position,
      :body, :audio_file, :cover_image
    )
  end
end
