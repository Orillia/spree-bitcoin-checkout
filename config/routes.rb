Rails.application.routes.draw do
  resource :bitcoin_checkout_notification,
    :only => :create
end
