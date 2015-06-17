class Ey::Core::Client
  class Real
    def get_messages(params={})
      query = Ey::Core.paging_parameters(params)
      require_parameters(params, "url")

      request(
        :params => params,
        :query  => query,
        :url    => params.delete("url"),
      )
    end
  end # Real
  class Mock
    def get_messages(params={})
      extract_url_params!(params)

      headers, messages_page = search_and_page(params, :messages, search_keys: %w[cluster slot database_server database_service request])

      response(
        :body    => {"messages" => messages_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
