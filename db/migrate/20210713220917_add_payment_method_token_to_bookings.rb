class AddPaymentMethodTokenToBookings < ActiveRecord::Migration[5.2]
  def change
    add_column :bookings, :payment_method_token, :string
  end
end
