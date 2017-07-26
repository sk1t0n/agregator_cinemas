class Movie < ApplicationRecord
  mount_uploader :image, ImageUploader
  validates :title, :age_rating, :country, :producer, :actors, :description, presence: true

  has_many :movie_sessions

  has_many :genre_movies
  has_many :genres, through: :genre_movies

  def all_genres
    self.genres.map(&:title).join(', ')
  end

  def all_genres=(titles)
    self.genres = titles.split(',').map do |title|
      Genre.where(title: title.downcase.strip).first_or_create!
    end
  end
end
