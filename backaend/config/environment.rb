# frozen_string_literal: true

require_relative "boot"
require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", "development").to_sym)

require_relative "../app/app"
