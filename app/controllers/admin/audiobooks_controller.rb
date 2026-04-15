class Admin::AudiobooksController < Admin::BaseController
  before_action :set_book, only: [:new, :create]
  before_action :set_audiobook, only: [:show, :edit, :update, :destroy]

  def index
    @audiobooks = Audiobook.includes(:book, audio_file_attachment: :blob)
                           .order(:book_id, :locale)
  end

  def show; end

  def new
    @audiobook = (@book&.audiobooks || Audiobook).new(locale: "en")
  end

  def create
    @audiobook = @book.audiobooks.new(audiobook_params)
    if @audiobook.save
      redirect_to admin_book_path(@book), notice: "Audiobook created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @audiobook.update(audiobook_params)
      redirect_to admin_audiobook_path(@audiobook), notice: "Audiobook updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    book = @audiobook.book
    @audiobook.destroy
    redirect_to admin_book_path(book), notice: "Audiobook deleted."
  end

  private

  def set_book
    @book = Book.friendly.find(params[:book_id])
  end

  def set_audiobook
    @audiobook = Audiobook.includes(:book, audio_file_attachment: :blob).find(params[:id])
  end

  def audiobook_params
    params.require(:audiobook).permit(:title, :locale, :duration_seconds, :position, :audio_file)
  end
end
