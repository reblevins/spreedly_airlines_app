Rails.application.routes.draw do
  resources :flights do
    resources :bookings
  end
  resources :airports
  resources :transactions
  resources :payment_methods

  get "/bookings", to: "bookings#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
