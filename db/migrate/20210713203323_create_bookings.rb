class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.belongs_to :flight, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :confirmation_code

      t.timestamps
    end
  end
end
