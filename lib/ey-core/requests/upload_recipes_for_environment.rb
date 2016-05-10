class Ey::Core::Client
  class Real
    def upload_recipes_for_environment(params={})
      file = params.delete("file")
      id   = params.delete("id")
      url  = params.delete("url")


      request(
        :body    => {"file" => Faraday::UploadIO.new(file, "application/x-gzip")},
        :headers => {"Content-Type" => "multipart/form-data" },
        :method  => :post,
        :path    => "environments/#{id}/recipes",
        :url     => url,
      )
    end
  end

  class Mock
    def upload_recipes_for_environment(params={})
    end
  end
end
