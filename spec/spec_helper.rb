ENV['MOCK_CORE'] ||= 'true'
ENV['CORE_URL'] ||= "http://api-development.localdev.engineyard.com:9292"

require 'pry'
require 'pry-nav'
require 'tempfile'

Bundler.require(:default, :test)

$:.unshift File.expand_path('../../lib', __FILE__)

Dir[File.expand_path("../{shared,support}/*.rb", __FILE__)].each{|f| require(f)}

require 'ey-core'
require 'ey-core/cli/main'


RSpec.configure do |config|
  config.order = "random"
  config.after(:each) do
    $stdout = STDOUT
    $stdin = STDIN
    $stderr = STDERR
  end
end
