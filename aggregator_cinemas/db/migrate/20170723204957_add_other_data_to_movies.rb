class AddOtherDataToMovies < ActiveRecord::Migration[5.1]
  def change
    add_column :movies, :trailer, :text
    add_column :movies, :images, :text
    add_column :movies, :premiere, :date
  end
end
