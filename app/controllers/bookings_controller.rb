require "net/http"
require "uri"
require "json"

class BookingsController < ApplicationController
  before_action :process_payment_method, only: :create
  attr_reader :transaction_data

  before_action :set_booking, only: %i[ show edit update destroy ]

  # GET /bookings or /bookings.json
  def index
    @bookings = Booking.all
  end

  # GET /bookings/1 or /bookings/1.json
  def show
    @full_transaction = Transaction.fetch_by_token(@booking.transaction_token) if @booking.transaction_token
    @transaction = Transaction.find_by(token: @booking.transaction_token)
    if @full_transaction["receiver"].class == Hash
      @response_body = JSON.parse(@full_transaction["response"]["body"])
      @full_transaction["amount"] = @response_body["amount"].to_i
    end
    @full_transaction["refunded"] = @transaction["refunded"]
  end

  # GET /bookings/new
  def new
    @booking = Booking.new({ first_name: "Rod", last_name: "Blev" })
    @flight = Flight.find(params[:flight_id])

    # For the booking payment form, we want to allow the user to use saved payment methods.
    # Retrieve payment methods stored in the db, then using the token, fetch the entire object from Spreedly.
    payment_method_tokens = PaymentMethod.all
    @payment_methods = []
    payment_method_tokens.each do |payment_method|
      full_payment_method = PaymentMethod.fetch_by_token(payment_method.token)
      full_payment_method["payment_method_id"] = payment_method["id"]
      @payment_methods.push(full_payment_method)
    end
  end

  # GET /bookings/1/edit
  def edit
  end

  # POST /bookings or /bookings.json
  def create
    @flight = Flight.find(params[:flight_id])

    if booking_params[:expedia] == "true"
      endpoint = "/receivers/2GrdVHzXyLwadFn6KlEuNMh7DBm/deliver.json"
      amount = (@flight.price * 100).to_i
      params = {
        "delivery": {
          "payment_method_token": @payment_method_token,
          "url": "https://spreedly-echo.herokuapp.com",
          "headers": "Content-Type: application/json",
          "body": "{ \"amount\": #{amount}, \"card_number\": \"{{credit_card_number}}\" }"
        }
      }
    else
      endpoint = "/gateways/ZqbGct8x6h9ud8ocm69BTaUvc0l/purchase.json"
      params = {
          "transaction": {
            "payment_method_token": @payment_method_token,
            "amount": @flight.price * 100,
            "currency_code": "USD",
            "retain_on_success": booking_params[:retain_on_success] == 'retain'
          }
        }
    end

    data = helpers.spreedly_post(endpoint, params)
    @transaction_data = data['transaction']
    if @transaction_data['succeeded']
      bp = booking_params
      bp["transaction_token"] = @transaction_data["token"]
      bp.delete(:payment_method_id)
      bp.delete(:expedia)
      bp.delete(:retain_on_success)
      @booking = Booking.new(bp)

      # If the customer has opted-in to save the payment method, also save a record of it in the local db.
      # Only the token is really necessary, because we wil retrieve the entire payment method for the new booking form.
      if @transaction_data['payment_method']['storage_state'] == 'cached' && booking_params[:payment_method_id] == "" && booking_params[:retain_on_success] == 'retain'
        payment_method_params = {
          "token": @transaction_data['payment_method']['token'],
          "last_four_digits": @transaction_data['payment_method']['last_four_digits'],
          "full_name": @transaction_data['payment_method']['full_name']
        }
        payment_method = PaymentMethod.new(payment_method_params)
        payment_method.save
      end

      # Save transaction token since, like payment methods, we wil retrieve the entire transaction for the index method/
      transaction_params = {
        "token": @transaction_data['token']
      }
      transaction = Transaction.new(transaction_params)
      transaction.save

      respond_to do |format|
        if @booking.save
          format.html { redirect_to flight_booking_path(@booking.flight_id, @booking), notice: "Booking was successfully created." }
          format.json { render :show, status: :created, location: @booking }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        end
      end
    else
      bp = booking_params
      bp.delete(:payment_method_id)
      bp.delete(:expedia)
      bp.delete(:retain_on_success)
      @booking = Booking.new(bp)
      @booking.errors[:base] << transaction_data['message']
      payment_method_tokens = PaymentMethod.all
      @payment_methods = []
      payment_method_tokens.each do |payment_method|
        full_payment_method = PaymentMethod.fetch_by_token(payment_method.token)
        full_payment_method["payment_method_id"] = payment_method["id"]
        @payment_methods.push(full_payment_method)
      end
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @booking.errors, status: :unprocessable_entity }
      end
    end
  end

  # Really only severs one purpose, to cancel a booking and refund the transaction
  def update
    @transaction = Transaction.find_by(token: @booking.transaction_token)
    transaction_response = @transaction.refund
    respond_to do |format|
      if (transaction_response["transaction"]["succeeded"] == true)
        @transaction.refunded = true
        @transaction.save
        @booking.canceled = true
        if @booking.save
          format.html { redirect_to bookings_path, notice: "Booking was successfully canceled." }
          format.json { render :show, status: :ok, location: @booking }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @booking.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to bookings_path, notice: transaction_response["transaction"]["succeeded"] }
        format.json { render :show, status: :ok, location: @booking }
      end
    end
  end

  # DELETE /bookings/1 or /bookings/1.json
  def destroy
    @flight = Flight.find(params[:flight_id])
    @booking = @flight.bookings.find(params[:id])
    @booking.destroy
    respond_to do |format|
      format.html { redirect_to bookings_url, notice: "Booking was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_booking
      @booking = Booking.find(params[:id])
    end

    def process_payment_method
      # If they have chosen to use a previously saved payment method, the payment_method_id will be passed in.
      if booking_params[:payment_method_id] != ""
        @payment_method = PaymentMethod.find(booking_params[:payment_method_id])
        valid = card_valid?(@payment_method["token"])
        if !valid[:succeeded]
          bp = booking_params
          bp.delete(:payment_method_id)
          bp.delete(:expedia)
          bp.delete(:retain_on_success)
          @booking = Booking.new(bp)
          @booking.errors[:base] << valid[:message]
          @flight = Flight.find(params[:flight_id])
          respond_to do |format|
            format.html { render :new, status: :unprocessable_entity }
            format.json { render json: @booking.errors, status: :unprocessable_entity }
          end
        end
        @payment_method_token = @payment_method.token
      else
        @payment_method_token = booking_params[:payment_method_token]
      end
    end

    # Only allow a list of trusted parameters through.
    def booking_params
      params.require(:booking).permit(:flight_id, :first_name, :last_name, :payment_method_token, :transaction_token, :payment_method_id, :retain_on_success, :expedia, :canceled)
    end
    
    def cleaned_booking_params(key = nil, value = nil)
      bp = {}
      bp[key] = value if key
      bp = booking_params
      bp.delete(:payment_method_id)
      bp.delete(:expedia)
      bp.delete(:retain_on_success)
      bp
    end

    def transaction_data
      @transaction_data
    end

    def card_valid?(payment_method_token)
      params = {
          "transaction": {
            "payment_method_token": payment_method_token
          }
        }
      endpoint = "/gateways/ZqbGct8x6h9ud8ocm69BTaUvc0l/verify.json"
      data = helpers.spreedly_post(endpoint, params)
      transaction_data = data['transaction']
      if transaction_data["succeeded"]
        { "succeeded": true }
      else
        { "succeeded": false, "message": transaction_data["response"]["message"] }
        # { "succeeded": false, "message": "You screwed up!" }
      end
    end
end
