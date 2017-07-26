class CreateMovieSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :movie_sessions do |t|
      t.date :date
      t.time :time
      t.string :format
      t.integer :price
      t.belongs_to :cinema, foreign_key: true
      t.belongs_to :movie, foreign_key: true

      t.timestamps
    end
  end
end
