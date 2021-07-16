class PaymentMethodsController < ApplicationController
  def index
    @payment_methods = PaymentMethod.all
  end

  def destroy
    @payment_method = PaymentMethod.find(params[:id])
    @payment_method.destroy
    respond_to do |format|
      format.html { redirect_to payment_methods_url, notice: "Payment method was successfully destroyed." }
      format.json { head :no_content }
    end
  end
end
