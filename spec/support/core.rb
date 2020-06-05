if ENV['MOCK_CORE'] == 'true'
  Ey::Core::Client.mock!
end

Ey::Core::Client::Mock.timeout = 0.1
Ey::Core::Client::Mock.poll_interval = 0

Ey::Core::Client::Real.timeout = 3
Ey::Core::Client::Real.poll_interval = 0

RSpec.configure do |config|
  config.before(:each) do
    if Ey::Core::Client.mocking?
      Ey::Core::Client::Mock.reset!
    elsif defined?(client) && client
      client.reset! unless ENV["RESET"] == "false"
    end
  end

  config.filter_run_excluding(Ey::Core::Client.mocking? ? {real_only: true} : { mock_only: true })
end
