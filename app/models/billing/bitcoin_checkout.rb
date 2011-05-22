class Billing::BitcoinCheckout < BillingIntegration
  preference :account, :string
  preference :api_key, :string
  preference :api_url, :string
end
