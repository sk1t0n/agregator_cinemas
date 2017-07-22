class GenresController < ApplicationController
  def index
    @genres = Genre.paginate(page: params[:page], per_page: 5)
  end

  def show
    genre = Genre.find_by(title: params[:id])
    @title = genre == nil ? '' : genre.title
    @movies = Movie.where(:id => GenreMovie.select(:movie_id).where(genre_id: Genre.select(:id).where(title: @title)))
      .paginate(page: params[:page], per_page: 2)
  end
end