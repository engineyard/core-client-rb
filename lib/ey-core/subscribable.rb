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

      deferred = client.subscribe(subscription) do |message|
        block.call(JSON.load(message))
      end

      deferred.callback do
        block.call({"meta" => true, "created_at" => Time.now,"message" => "successfully subscribed"})
      end

      deferred.errback do |error|
        block.call({"meta" => true, "created_at" => Time.now, "message" => "subscription failed: #{error.inspect}"})
        EM.stop_event_loop
      end

      EventMachine::PeriodicTimer.new(5) do
        if resource.reload.ready?
          block.call({"meta" => true, "created_at" => Time.now, "message" => "#{resource} is finished"})
          EM.stop_event_loop
        end
      end
    end
  end
end
