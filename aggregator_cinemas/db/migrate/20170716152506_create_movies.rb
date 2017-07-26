class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :description
      t.string :duration
      t.string :age_rating
      t.string :country
      t.string :director
      t.string :budget
      t.text :actors
      t.text :trailer
      t.text :images
      t.date :premiere
      t.float :rating_kinopoisk
      t.integer :voice_kinopoisk
      t.float :rating_imdb
      t.integer :voice_imdb
      t.string :image

      t.timestamps
    end
  end
end
