class Ey::Core::Client
  class Real
    def destroy_logical_database(params={})
      id  = params["id"]
      url = params.delete("url")

      request(
        :path   => "/logical-databases/#{id}",
        :url    => url,
        :method => :delete,
      )
    end
  end

  class Mock
    def destroy_logical_database(params={})
      extract_url_params!(params)
      request_id = self.uuid

      logical_database_id = params["id"] || params["logical_database"]

      logical_database = self.find(:logical_databases, logical_database_id)

      request = {
        "resource"    => [:logical_databases, logical_database_id, logical_database.merge("deleted_at" => Time.now)],
        "type"        => "deprovision_logical_database",
        "started_at"  => Time.now,
        "finished_at" => nil,
        "successful"  => "true",
        "id"          => request_id,
      }

      self.data[:requests][request_id] = request

      response(
        :body   => {"request" => {id: request_id}},
        :status => 201,
      )
    end
  end
end
