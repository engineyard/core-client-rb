class Ey::Core::Client
  class Real
    def authorized_channel(path)
      request(
        :path   => "/channels",
        :params => {"channel" => {"path" => path}}
      )
    end
  end # Real

  class Mock
    def authorized_channel(path)
      if task = self.data[:tasks].values.find { |t| Addressable::URI.parse(t["read_channel"]).query_values["subscription"] == path }
        response(
          :body => {"task" => task},
        )
      else
        response(status: 404, :body => {"errors" => ["Couldn't find Awsm::Task with [channel_path: #{path}]"]})
      end
    end
  end # Mock
end # Ey::Core::Client
