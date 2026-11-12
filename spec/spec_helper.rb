# frozen_string_literal: true

require 'chefspec'
require 'chefspec/policyfile'

RSpec.configure do |config|
  config.platform = 'windows'
  config.version = '2022'
end
