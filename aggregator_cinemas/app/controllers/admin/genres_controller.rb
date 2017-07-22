class Admin::GenresController < Admin::AdminController
  before_action :set_genre, only: [:edit, :update, :destroy]

  def new
    @genre = Genre.new
  end

  def create
    @genre = Genre.new(genre_params)
    if @genre.save
      redirect_to genres_path, success: 'Жанр успешно создан.'
    else
      flash.now[:danger] = 'Создать жанр не удалось.'
      render :new
    end
  end

  def edit
  end

  def update
    if @genre.update_attributes(genre_params)
      redirect_to genres_path, success: 'Жанр успешно обновлен.'
    else
      flash.now[:danger] = 'Жанр не обновлен.'
      render :edit
    end
  end

  def destroy
    if @genre.movies.empty?
      @genre.destroy
      redirect_to genres_path, success: 'Жанр успешно удален.'
    else
      redirect_to genres_path, danger: 'Удаление не удалось. У жанра есть фильмы.'
    end
  end

  private

  def set_genre
    @genre = Genre.find(params[:id])
  end

  def genre_params
    params.require(:genre).permit(:title)
  end
end