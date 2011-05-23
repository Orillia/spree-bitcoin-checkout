module Spree
  module BitcoinCheckout
    def self.included(base)
      base.before_filter :redirect_to_bitcoin_central_if_needed, 
        :only => [:update]
    end

    def redirect_to_bitcoin_central_if_needed
      if should_redirect_to_bitcoin_sci?
        create_invoice_through_api!
        redirect_to "https://bitcoin-central.net/invoices"
      end
    end
  
    def should_redirect_to_bitcoin_sci?    
      params[:state] == "payment" &&
        (PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]).type.to_s =~ /BitcoinCheckout/)
    end

    def create_invoice_through_api!
      require "net/https"
      require "uri"
      
      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      
      base_url = AppConfiguration.first.preferred_site_url.gsub(/\/$/, "")
      callback_url = [base_url, bitcoin_checkout_notification_path].join

      user = payment_method.preferred_user
      password = payment_method.preferred_password

      uri = URI.parse(payment_method.preferred_api_url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(user, password)
      request.set_form_data({
          "invoice[merchant_reference]" => @order.number,
          "invoice[merchant_memo]" => "Payment for order #{@order.number}",
          "invoice[amount]" => @order.total.to_s,
          "invoice[callback_url]" => callback_url,
          "invoice[item_url]" => order_path(@order)
        }
      )
    
      http.request(request)
    end  
  end
end