class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
      t.string :flight_number
      t.integer :origin_id
      t.integer :destination_id
      t.datetime :start_time
      t.integer :duration
      t.float :price

      t.timestamps
    end
  end
end
