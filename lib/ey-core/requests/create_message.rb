class Ey::Core::Client
  class Real
    def create_message(_params={})
      params, _ = require_arguments(_params, "url")

      request(
        :method => :post,
        :url    => params.delete("url"),
        :body   => params,
      )
    end
  end

  class Mock
    def create_message(_params={})
      params, _ = require_arguments(_params, "url")

      extract_url_params!(params)

      message_id = self.uuid

      params.merge!(
        "id"         => message_id,
        "created_at" => Time.now,
      )

      self.data[:messages][message_id] = params

      response(
        :body   => {"message" => params},
        :status => 201,
      )
    end
  end
end
