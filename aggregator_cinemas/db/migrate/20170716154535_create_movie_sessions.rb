class CreateMovieSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :movie_sessions do |t|
      t.time :duration
      t.string :description
      t.integer :price
      t.date :date

      t.timestamps
    end
  end
end
