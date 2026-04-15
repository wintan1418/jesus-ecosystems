class Admin::ChaptersController < Admin::BaseController
  before_action :set_book, only: [:new, :create]
  before_action :set_chapter, only: [:show, :edit, :update, :destroy]

  def index
    @chapters = Chapter.includes(:book).order(:book_id, :locale, :position)
    @chapters = @chapters.where(locale: params[:locale]) if params[:locale].present?
    @chapters = @chapters.where(book_id: params[:book_id]) if params[:book_id].present?
  end

  def show; end

  def new
    @chapter = (@book&.chapters || Chapter).new(locale: "en", position: next_position)
  end

  def create
    @chapter = @book.chapters.new(chapter_params)
    if @chapter.save
      redirect_to admin_book_path(@book), notice: "Chapter created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @chapter.update(chapter_params)
      redirect_to admin_chapter_path(@chapter), notice: "Chapter updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    book = @chapter.book
    @chapter.destroy
    redirect_to admin_book_path(book), notice: "Chapter deleted."
  end

  private

  def set_book
    @book = Book.friendly.find(params[:book_id])
  end

  def set_chapter
    @chapter = Chapter.includes(:book).find(params[:id])
  end

  def next_position
    (@book&.chapters&.maximum(:position) || 0) + 1
  end

  def chapter_params
    params.require(:chapter).permit(:title, :locale, :is_preview, :position, :body)
  end
end
