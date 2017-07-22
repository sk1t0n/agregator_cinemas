class MoviesController < ApplicationController
  before_action :set_movie, only: :show

  def index
    @movies = Movie.paginate(page: params[:page], per_page: 3)
  end

  def show
  end

  private

  def set_movie
    @movie = Movie.find_by(:id => params[:id])
    if @movie == nil
      render :show
    end
  end
end