class Ey::Core::Client
  class Real
    def download_file(params={})
      url = params["url"]

      request(
        :method => :get,
        :url    => url,
      )
    end
  end # Real

  class Mock
    def download_file(params={})
      url = params["url"]

      body = File.read(self.data[:temp_files][url])

      response(
        :body   => body,
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client
