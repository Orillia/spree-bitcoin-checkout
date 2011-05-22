Rails.application.routes.draw do
  resources :bitcoin_checkout_notification,
    :only => :create
end
