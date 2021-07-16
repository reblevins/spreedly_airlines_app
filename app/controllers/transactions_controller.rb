class TransactionsController < ApplicationController
  def index
    @transaction_tokens = Transaction.all
    @transactions = Array.new
    @transaction_tokens.each do |transaction|
      full_transaction = Transaction.fetch_by_token(transaction.token)
      full_transaction[:id] = transaction[:id]
      full_transaction[:refunded] = transaction[:refunded]
      if full_transaction["receiver"].class == Hash
        response_body = JSON.parse(full_transaction["response"]["body"])
        full_transaction["amount"] = response_body["amount"]
      end
      @transactions.push(full_transaction)
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: "Transaction was successfully deleted." }
      format.json { head :no_content }
    end
  end
end
