class Ey::Core::Client
  class Real
    def get_kubey_cluster(params={})
      url = params.delete("url")

      request(
        :url  => url,
      )
    end
  end

  class Mock
    def get_kubey_cluster(params={})
      #TODO: mocks needed?
      response(status: 404)
    end
  end
end
