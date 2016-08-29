require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |config|
  config.platform = 'windows'
  config.version = '2012R2'
  config.color = true
  config.log_level = :error
end
