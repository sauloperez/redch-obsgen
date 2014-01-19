require './lib/obsgen.rb'

require 'bundler/setup'
Bundler.require :default, :test

require 'open4'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def valid_json?(json)
  JSON.parse(json)
rescue JSON::ParseError
  false
end
