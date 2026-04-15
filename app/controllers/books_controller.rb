class BooksController < ApplicationController
  def index
    @books = Book.published.ordered.with_attached_cover_image.includes(:translations)
    set_meta_tags title:       I18n.t("books.index.meta_title", default: "The Books"),
                  description: I18n.t("home.subhead")
  end

  def show
    @book = Book.published.with_attached_cover_image
                .includes(:translations, :audiobooks, chapters: { rich_text_body: :embeds_attachments })
                .friendly.find(params[:slug])

    @preview_chapters = @book.chapters.for_locale(I18n.locale).preview.ordered
    @gated_chapters   = @book.chapters.for_locale(I18n.locale).where(is_preview: false).ordered
    @audiobook        = @book.audiobooks.for_locale(I18n.locale).first

    set_meta_tags title:       @book.localized_title(I18n.locale),
                  description: @book.localized_description(I18n.locale)
  end

  # 3D flip-book reader. Renders cover → title → each chapter as facing pages,
  # with locked chapters showing only their title and an unlock CTA.
  def read
    @book = Book.published.with_attached_cover_image
                .includes(:translations, chapters: { rich_text_body: :embeds_attachments })
                .friendly.find(params[:slug])

    @chapters = @book.chapters.for_locale(I18n.locale).ordered

    set_meta_tags title:       "#{@book.localized_title(I18n.locale)} — Reader",
                  description: @book.localized_description(I18n.locale)

    render layout: "reader"
  end
end
