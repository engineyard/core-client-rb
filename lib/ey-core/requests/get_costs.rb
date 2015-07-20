class Ey::Core::Client
  class Real
    def get_costs(params={})
      request(
        :url  => params.delete("url"),
        :path => "/accounts/#{params[:id]}/costs"
      )
    end
  end

  class Mock
    def get_costs(params={})
      extract_url_params!(params)

      response(
        :body    => {"costs" => self.data[:costs]},
        :status  => 200
      )
    end
  end
end
