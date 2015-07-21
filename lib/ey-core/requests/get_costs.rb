class Ey::Core::Client
  class Real
    def get_costs(params={})
      url = params.delete("url")
      account_id = params.delete("id")

      request(
        url:   url,
        path:  "/accounts/#{account_id}/costs",
        query: params
      )
    end
  end

  class Mock
    def get_costs(params={})
      extract_url_params!(params)

      response(
        body:   {"costs" => self.data[:costs]},
        status: 200
      )
    end
  end
end
