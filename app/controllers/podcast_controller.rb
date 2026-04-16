class PodcastController < ApplicationController
  def index
    @episodes = Episode.published.for_locale(I18n.locale)
                       .ordered
                       .with_attached_audio_file
                       .with_attached_cover_image
                       .limit(100)

    set_meta_tags title:       "#{SiteSetting['podcast_title'].presence || 'The Ecosystem Podcast'} · #{t('site.name')}",
                  description: SiteSetting["podcast_subtitle"].presence || "Field notes from the movement."

    respond_to do |format|
      format.html
      format.rss { render layout: false }
    end
  end

  def show
    @episode = Episode.published.for_locale(I18n.locale)
                      .with_attached_audio_file
                      .with_attached_cover_image
                      .friendly.find(params[:slug])

    set_meta_tags title:       "#{@episode.title} · #{SiteSetting['podcast_title'].presence || 'Podcast'}",
                  description: @episode.description
  rescue ActiveRecord::RecordNotFound
    redirect_to podcast_path, alert: "Episode not found."
  end
end
