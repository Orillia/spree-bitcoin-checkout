require 'spree_core'
require 'spree_bitcoin_checkout_hooks'

module SpreeBitcoinCheckout
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end

      Billing::BitcoinCheckout.register
      
      CheckoutController.class_eval do
        include Spree::BitcoinCheckout
      end
    end

    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    config.to_prepare &method(:activate).to_proc
  end
end
