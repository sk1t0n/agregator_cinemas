class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :image
      t.float :rating_kinopoisk
      t.float :rating_imdb
      t.integer :voice_kinopoisk
      t.integer :voice_imdb
      t.string :age_rating
      t.time :duration
      t.string :country
      t.string :producer
      t.string :budget
      t.text :actors
      t.text :description

      t.timestamps
    end
  end
end
