class AddCanceledToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :canceled, :boolean
  end
end
