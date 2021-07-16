class CreatePaymentMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_methods do |t|
      t.string :token
      t.string :last_four_digits
      t.string :full_name

      t.timestamps
    end
  end
end
