require 'cucumber/rspec/doubles'

# Set up the mocks. Ookla would approve.
Ey::Core::Client.mock!
Ey::Core::Client::Mock.timeout = 0.1
Ey::Core::Client::Mock.poll_interval = 0
Ey::Core::Client::Real.timeout = 3
Ey::Core::Client::Real.poll_interval = 0

Before do
  # Reset the mocked API before every scenario
  Ey::Core::Client::Mock.reset!

  # Stub out `#core_client` on all subcommands to ensure that they're using
  # the mocked client. Otherwise, everything turns to calamity, because the
  # mocked API is silly.
  allow_any_instance_of(Ey::Core::Cli::Subcommand).
    to receive(:core_client).
    and_return(client)
end
