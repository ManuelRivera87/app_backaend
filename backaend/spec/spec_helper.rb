# frozen_string_literal: true

ENV["RACK_ENV"] = "test"

require "rack/test"
require "rspec"
require_relative "../config/environment"

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.order = :random
  config.before do
    Producto.reset!
    App.set :quotes, []
    App.set :next_quote_id, 1
  end
end

def app
  App
end
