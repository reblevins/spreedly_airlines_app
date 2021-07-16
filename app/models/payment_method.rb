class PaymentMethod < ApplicationRecord
  def self.fetch_by_token(token)
    endpoint = "/payment_methods/#{token}.json"
    data = ApplicationController.helpers.spreedly_get(endpoint)
    data['payment_method']
  end
end
