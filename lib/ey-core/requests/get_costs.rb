class Ey::Core::Client
  class Real
    def get_costs(params={})

    end
  end

  class Mock
    def get_costs(params={})
      extract_url_params!(params)

      account = params.delete("account")

      headers, costs_page = search_and_page(params, :costs, search_keys: %w[account billing_month levels description])

      response(
        :body    => {"costs" => costs_page},
        :status  => 200,
        :headers => headers
      )
    end
  end
end
