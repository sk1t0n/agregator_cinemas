class CinemasController < ApplicationController
  before_action :add_cinema_ids
  
  def index
    @cinemas = Cinema.all
  end
  
  def show
    @cinema = Cinema.find_by(id: params[:id])
    @sessions = MovieSession.where(cinema_id: params[:id]).paginate(page: params[:page], per_page: 20)
    @hash_movie_id_title = {}
    Movie.all.each do |movie|
      @hash_movie_id_title[movie.id] = movie.title
    end
  end
end
