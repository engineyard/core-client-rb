class Ey::Core::Client
  class Real
    def upload_file(_params={})
      params = Cistern::Hash.stringify_keys(_params)

      mime_type  = params["mime_type"]
      upload_url = params["upload_url"]

      if string = params["body"]
        request(
          :method  => :put,
          :headers => {"Content-Type" => mime_type},
          :url     => upload_url,
          :body    => string,
        )
      else
        request(
          :method  => :put,
          :headers => {"Content-Type" => "multipart/form-data"},
          :url     => upload_url,
          :body    => Faraday::UploadIO.new(params.fetch("file"), mime_type),
        )
      end
    end
  end # Real

  class Mock
    def upload_file(_params={})
      params = Cistern::Hash.stringify_keys(_params)
      upload_url = params["upload_url"]

      temp_file = Tempfile.new("ey-core")
      temp_file.write(params["body"] || File.read(params.fetch("file")))
      temp_file.close

      self.data[:temp_files][upload_url] = temp_file.path

      response(
        :body   => "",
        :status => 200,
      )
    end
  end # Mock
end # Ey::Core::Client
