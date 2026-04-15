class AudiobooksController < ApplicationController
  def index
    @audiobooks = Audiobook.for_locale(I18n.locale)
                           .ordered
                           .with_attached_audio_file
                           .includes(book: { cover_image_attachment: :blob })

    @current = @audiobooks.find { |ab| ab.id.to_s == params[:track] } || @audiobooks.first

    set_meta_tags title:       I18n.t("audiobooks.index.heading_1") + " " + I18n.t("audiobooks.index.heading_2"),
                  description: I18n.t("audiobooks.index.subhead")
  end

  def show
    redirect_to audiobooks_path(track: params[:id])
  end
end
