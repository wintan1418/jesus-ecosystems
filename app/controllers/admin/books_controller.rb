class Admin::BooksController < Admin::BaseController
  before_action :set_book, only: [:show, :edit, :update, :destroy]

  def index
    @books = Book.ordered.with_attached_cover_image
                 .includes(:translations, :chapters, :audiobooks)
  end

  def show
    @chapters     = @book.chapters.ordered
    @translations = @book.translations
    @audiobooks   = @book.audiobooks.ordered
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to admin_book_path(@book), notice: "Book created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @book.update(book_params)
      redirect_to admin_book_path(@book), notice: "Book updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to admin_books_path, notice: "Book deleted."
  end

  private

  def set_book
    @book = Book.with_attached_cover_image.friendly.find(params[:id])
  end

  def book_params
    params.require(:book).permit(
      :title, :volume_number, :tagline, :description,
      :published_at, :position, :cover_image
    )
  end
end
