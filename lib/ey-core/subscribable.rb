module Ey::Core::Subscribable
  def self.included(klass)
    klass.send(:attribute, :read_channel)
  end

  def read_channel_uri
    self.read_channel && Addressable::URI.parse(self.read_channel)
  end

  def subscribe(&block)
    return false unless read_channel_uri

    gem 'faye', '~> 1.1'
    require 'faye' # soft dependency

    uri = read_channel_uri

    resource = self

    url          = uri.omit(:query).to_s
    token        = uri.query_values["token"]
    subscription = uri.query_values["subscription"]

    EM.run do
      client = Faye::Client.new(url)
      client.set_header("Authorization", "Token #{token}")
      next_ready_check = Time.now + 5
      handle_output = Proc.new do |m|
        next_ready_check = Time.now + 1
        block.call(m)
      end

      deferred = client.subscribe(subscription) do |message|
        handle_output.call(JSON.load(message))
      end

      deferred.callback do
        handle_output.call({"meta" => true, "created_at" => Time.now,"message" => "log output stream connection established, waiting...\n"})
      end

      deferred.errback do |error|
        handle_output.call({"meta" => true, "created_at" => Time.now, "message" => "failed to stream output: #{error.inspect}\n"})
        EM.stop_event_loop
      end

      EventMachine::PeriodicTimer.new(1) do
        if Time.now > next_ready_check
          if resource.reload.ready?
            handle_output.call({"meta" => true, "created_at" => Time.now, "message" => "#{resource} finished"})
            EM.stop_event_loop
          end
          next_ready_check = Time.now + 5
        end
      end
    end
  end
end
