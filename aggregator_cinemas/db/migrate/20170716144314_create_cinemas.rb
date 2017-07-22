class CreateCinemas < ActiveRecord::Migration[5.1]
  def change
    create_table :cinemas do |t|
      t.string :title
      t.text :description
      t.text :equipment
      t.text :contacts
      t.text :discounts
      t.string :logo
      t.string :location

      t.timestamps
    end
  end
end
