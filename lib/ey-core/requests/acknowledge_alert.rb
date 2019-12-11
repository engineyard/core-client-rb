class Ey::Core::Client
  class Real
    def acknowledge_alert(params={})
      id = params.delete("id")

      request(
        method: :put,
        path: "legacy-alerts/#{id}/acknowledge"
      )
    end
  end

  class Mock
    def acknowledge_alert(params={})
      id = params.delete("id")

      if alert = self.data[:alerts][id]
        alert["acknowledged"] = true

        response(
          :body => {"legacy_alert" => alert},
          :status => 200
        )
      else
        response(status: 404)
      end
    end
  end
end
