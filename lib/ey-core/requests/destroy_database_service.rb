class Ey::Core::Client
  class Real
    def destroy_database_service(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/database-services/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_database_service(params={})
      extract_url_params!(params)
      request_id = self.uuid

      database_service_id = params["id"] || params["database_service"]

      database_service = self.find(:database_services, database_service_id)

      request = {
        "finished_at" => nil,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "type"        => "deprovision_database_service",
        "resource"    => [:database_services, database_service_id, lambda do |r|
          database_service.merge!("deleted_at" => Time.now)

          self.data[:database_servers].values.
            select { |ds| ds["database_service"] == url_for("/database-services/#{database_service["id"]}") }.
            each { |ds|
              self.data[:database_server_firewalls].select { |ds_id, _| ds["id"] == ds_id }.
                each { |_, f_id| self.data[:firewalls][f_id].merge!("deleted_at" => Time.now) }
            }.
            each { |ds| ds["deleted_at"] = Time.now }

          self.data[:logical_databases].values.
            select { |ds| ds["service"] == url_for("/database-services/#{database_service["id"]}") }.
            each   { |ds| ds["deleted_at"] = Time.now }

          r.delete("resource_url")
        end],
      }

      self.data[:requests][request_id] = request

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
