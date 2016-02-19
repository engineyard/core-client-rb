class Ey::Core::Client
  class Real
    def get_token(options={})
      id  = options.delete("id")
      url = options.delete("url")

      request(
        :path => "tokens/#{id}",
        :url  => url,
      )
    end
  end

  class Mock
    def get_token(options={})
      response(
        :body => {"token" => self.find(:tokens, resource_identity(options))},
      )
    end
  end
end
