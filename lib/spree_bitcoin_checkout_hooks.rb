class SpreeBitcoinCheckoutHooks < Spree::ThemeSupport::HookListener
  insert_after :outside_cart_form, 'shared/bitcoin_checkout_button'
end