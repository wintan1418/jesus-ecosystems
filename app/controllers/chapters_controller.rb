class ChaptersController < ApplicationController
  def show
    @book = Book.published.friendly.find(params[:book_slug])
    @chapter = @book.chapters
                    .for_locale(I18n.locale)
                    .friendly
                    .find(params[:slug])

    # Public visitors can only read preview chapters. Locked chapters
    # bounce to the free-copy request page with a flash hint.
    unless @chapter.is_preview?
      redirect_to(request_free_copy_path,
                  alert: t("chapters.show.locked_alert", default: "That chapter unlocks with a free hardcopy."))
      return
    end

    set_meta_tags title:       "#{@chapter.title} · #{@book.localized_title(I18n.locale)}",
                  description: @book.localized_description(I18n.locale)
  end
end
