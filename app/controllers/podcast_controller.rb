class PodcastController < ApplicationController
  def index
    @episodes = Episode.published.for_locale(I18n.locale)
                       .ordered
                       .with_attached_audio_file
                       .with_attached_cover_image
                       .limit(100)

    set_meta_tags title:       "#{cms('podcast_title', default: 'The Ecosystem Podcast')} · #{t('site.name')}",
                  description: cms("podcast_subtitle", default: "Field notes from the movement.")

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

    set_meta_tags title:       "#{@episode.title} · #{cms('podcast_title', default: 'Podcast')}",
                  description: @episode.description
  rescue ActiveRecord::RecordNotFound
    redirect_to podcast_path, alert: "Episode not found."
  end
end
