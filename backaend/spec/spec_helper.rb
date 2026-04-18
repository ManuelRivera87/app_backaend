# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "rack/test"
require "rspec"
require_relative "../config/environment"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.order = :random
end

def app
  App
end
