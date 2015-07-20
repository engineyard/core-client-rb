class Ey::Core::Client
  class Real
    def get_gem(params={})
      id = params.delete("id")

      request(
        :path => "gems/#{id}",
      )
    end
  end

  class Mock
    def get_gem(params={})
      response(
        :body => {
          "gem" => {
            "name" => params["id"],
            "current_version" => Ey::Core::VERSION,
          }
        }
      )
    end
  end
end
