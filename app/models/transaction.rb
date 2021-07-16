class Transaction < ApplicationRecord
  def self.fetch_by_token(token)
    endpoint = "/transactions/#{token}.json"
    data = ApplicationController.helpers.spreedly_get(endpoint)
    data['transaction']
  end

  def refund
    endpoint = "/transactions/#{token}/credit.json"
    data = ApplicationController.helpers.spreedly_post(endpoint)
    # { "succeeded": data["transaction"]["succeeded"], "message": data["transaction"]["message"] }
  end
end
