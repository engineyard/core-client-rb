class Ey::Core::Client
  class Real
    def request_callback(options={})
      (url = options["url"]) || (id = options.fetch("id"))

      request(
        :path   => "/requests/#{id}/callback",
        :method => :post,
        :url    => url,
      )
    end
  end

  class Mock
    def request_callback(options={})
      request_id = resource_identity(options)

      request = find(:requests, request_id).dup
      request.delete("resource")

      response(
        :body => {"request" => request},
      )
    end
  end
end
