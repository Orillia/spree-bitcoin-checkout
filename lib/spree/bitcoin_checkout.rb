module Spree
  module BitcoinCheckout
    def self.included(base)
      base.before_filter :redirect_to_bitcoin_central_if_needed, 
        :only => [:update]
    end

    def redirect_to_bitcoin_central_if_needed
      if should_redirect_to_bitcoin_sci?
        redirect_to create_invoice_through_api!
      end
    end
  
    def should_redirect_to_bitcoin_sci?    
      params[:state] == "payment" &&
        (PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]).type.to_s =~ /BitcoinCheckout/)
    end

    def create_invoice_through_api!
      require "net/https"
      require "uri"
      require "json"
      
      payment_method = PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id])
      
      base_url = AppConfiguration.first.preferred_site_url.gsub(/\/$/, "")
      base_url = "http://#{base_url}" unless base_url =~ /^http/
      callback_url = [base_url, bitcoin_checkout_notification_path].join
      item_url = [base_url, order_path(@order)].join

      user = payment_method.preferred_user
      password = payment_method.preferred_password

      uri = URI.parse("#{payment_method.preferred_api_url}.json")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl

      request = Net::HTTP::Post.new(uri.request_uri)
      request.basic_auth(user, password)
      request.set_form_data({
          "invoice[merchant_reference]" => @order.number,
          "invoice[merchant_memo]" => "Payment for order #{@order.number}",
          "invoice[amount]" => @order.total.to_s,
          "invoice[callback_url]" => callback_url,
          "invoice[item_url]" => item_url
        }
      )
    
      response = http.request(request)
      Rails.logger.warn("**********************************************************")
      Rails.logger.warn(response.body)
      Rails.logger.warn("**********************************************************")
      JSON.parse(response.body)["invoice"]["public_url"]
    end  
  end
end