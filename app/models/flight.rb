class Flight < ApplicationRecord
  belongs_to :origin, class_name: :Airport
  belongs_to :destination, class_name: :Airport

  has_many :bookings

  def formatted_date
    start_time.strftime("%m/%d/%Y %l:%M%P")
  end
end
