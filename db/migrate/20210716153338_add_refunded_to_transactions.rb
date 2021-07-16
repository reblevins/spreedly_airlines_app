class AddRefundedToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :refunded, :boolean
  end
end
