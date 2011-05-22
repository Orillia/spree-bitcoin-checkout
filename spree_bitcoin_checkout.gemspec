Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_bitcoin_checkout'
  s.version     = '0.1'
  s.summary     = "Automatically integrate bitcoin-central.net's API"
  s.description = 'Leverages the invoicing API in order to seamlessly accept bitcoin denominated payments'
  s.required_ruby_version = '>= 1.8.7'

  s.author            = 'David FRANCOIS'
  s.email             = 'david@bitcoin-central.net'
  s.homepage          = 'https://bitcoin-central.net/'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

#  s.add_dependency('spree_core', '>= 0.60.0')
end
