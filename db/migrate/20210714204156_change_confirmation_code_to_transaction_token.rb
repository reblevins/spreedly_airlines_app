class ChangeConfirmationCodeToTransactionToken < ActiveRecord::Migration[5.2]
  def change
    rename_column :bookings, :confirmation_code, :transaction_token
  end
end
