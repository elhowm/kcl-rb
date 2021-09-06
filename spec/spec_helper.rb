require 'bundler/setup'
require 'kcl'

# load shared_contexts
Dir["#{__dir__}/supports/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  true
end
