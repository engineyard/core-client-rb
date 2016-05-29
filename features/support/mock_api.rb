Before do
  Cistern.formatter = Cistern::Formatter::AwesomePrint

  Ey::Core::Client.mock!

  Ey::Core::Client::Mock.timeout = 0.1
  Ey::Core::Client::Mock.poll_interval = 0

  Ey::Core::Client::Real.timeout = 3
  Ey::Core::Client::Real.poll_interval = 0

  Ey::Core::Client::Mock.reset!
end
