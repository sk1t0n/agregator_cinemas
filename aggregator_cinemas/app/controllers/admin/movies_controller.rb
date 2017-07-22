class Admin::MoviesController < Admin::AdminController
  before_action :set_movie, only: [:edit, :update, :destroy]

  def new
    @movie = Movie.new
  end

  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      redirect_to @movie, success: 'Фильм успешно добавлен в базу данных.'
    else
      flash.now[:danger] = 'Фильм не удалось добавить в базу данных.'
      render :new
    end
  end

  def edit
  end

  def update
    if @movie.update_attributes(movie_params)
      redirect_to @movie, success: 'Информация о фильме успешно обновлена в базе данных.'
    else
      flash.now[:danger] = 'Информация о фильме не обновлена в базе данных.'
      render :edit
    end
  end

  def destroy
    @movie.destroy
    redirect_to movies_path, success: 'Фильм успешно удален из базы данных.'
  end

  private

  def set_movie
    @movie = Movie.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title, :image, :rating_kinopoisk, :rating_imdb,
      :voice_kinopoisk, :voice_imdb, :age_rating, :duration, :country, :producer,
      :budget, :actors, :description, :all_genres)
  end
end