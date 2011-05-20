CheckoutController.class_eval do
  def update_with_redirect_to_bitcoin_sci
    if should_redirect_to_bitcoin_sci?
      create_invoice_through_api!
      redirect_to "https://bitcoin-central.net/invoices"
    else
      update_without_redirect_to_bitcoin_sci
    end
  end

  alias_method_chain :update, :redirect_to_bitcoin_sci

  def should_redirect_to_bitcoin_sci?
    params[:state] == "payment" &&
      (PaymentMethod.find(params[:order][:payments_attributes].first[:payment_method_id]).type.to_s =~ /BitcoinCheckout/)
  end

  def create_invoice_through_api!
    require "net/https"
    require "uri"

    order = current_order

    uri = URI.parse("https://bitcoin-central.net/invoices")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.basic_auth("user", "password")
    request.set_form_data({
        "invoice[merchant_reference]" => order.number,
        "invoice[merchant_memo]" => "Payment for order #{order.number}",
        "invoice[amount]" => order.total.to_s,
        "invoice[callback_url]" => "http://domain.tld/"
      }
    )
    response = http.request(request)
    puts response.body
    #    response.status
  end
end
