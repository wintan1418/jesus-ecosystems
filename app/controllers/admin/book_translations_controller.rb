class Admin::BookTranslationsController < Admin::BaseController
  before_action :set_book
  before_action :set_translation, only: [:edit, :update, :destroy]

  def index
    @translations = @book.translations
  end

  def new
    @translation = @book.translations.new(locale: "en")
  end

  def create
    @translation = @book.translations.new(translation_params)
    if @translation.save
      redirect_to admin_book_path(@book), notice: "Translation added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @translation.update(translation_params)
      redirect_to admin_book_path(@book), notice: "Translation updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @translation.destroy
    redirect_to admin_book_path(@book), notice: "Translation removed."
  end

  private

  def set_book
    @book = Book.friendly.find(params[:book_id])
  end

  def set_translation
    @translation = @book.translations.find(params[:id])
  end

  def translation_params
    params.require(:book_translation).permit(:locale, :title, :tagline, :description, :slug)
  end
end
