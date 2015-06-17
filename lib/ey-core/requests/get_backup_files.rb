class Ey::Core::Client
  class Real
    def get_backup_files(params={})
      query = Ey::Core.paging_parameters(params)
      url   = params.delete("url")

      request(
        :params => params,
        :path   => "/backup_files",
        :query  => query,
        :url    => url,
      )
    end
  end # Real
  class Mock
    def get_backup_files(params={})
      extract_url_params!(params)

      headers, backup_files_page = search_and_page(params, :backup_files, search_keys: %w[backup])

      response(
        :body    => {"backup_files" => backup_files_page},
        :status  => 200,
        :headers => headers
      )
    end
  end # Mock
end
