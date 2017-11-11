class Ey::Core::Client
  class Real
    def update_cdn_distribution(params={})
      id = params.delete("id")

      request(
        :method => :put,
        :path   => "/cdn-distributions/#{id}",
        :body   => params,
      )
    end
  end

  class Mock
    def update_cdn_distribution(params={})
      request_id = self.uuid
      cdn_distribution = self.find(:cdn_distributions, resource_identity(params))

      cdn_distribution.merge!(params["cdn_distribution"])

      request = {
        "id"          => request_id,
        "type"        => "update_cdn_distribution",
        "successful"  => "true",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "resource"    => [:cdn_distributions, cdn_distribution["id"], cdn_distribution]
      }

      self.data[:requests][request_id] = request

      response(
        :body => {
          "request" => request.dup.tap { |req| req.delete("resource") }
        }
      )
    end
  end
end
