class ChangeDateForDuration < ActiveRecord::Migration[5.1]
  def change
    change_column(:movies, :duration, :string)
  end
end
