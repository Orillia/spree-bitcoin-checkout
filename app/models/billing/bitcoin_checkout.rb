class Billing::BitcoinCheckout < BillingIntegration
  preference :user, :string
  preference :password, :string
  preference :api_url, :string
end
