class Ey::Core::Client
  class Real
    def destroy_environment_variable(params={})
      id  = params["id"]

      response = request(
        :path   => "/environment_variables/#{id}",
        :method => :delete,
      )
      response
    end
  end

  class Mock
    def destroy_environment_variable(params={})
      extract_url_params!(params)
      request_id = self.uuid

      environment_variable_id = params["id"] || params["environment_variable"]

      environment_variable = self.find(:environment_variables, environment_variable_id)

      request = {
        "finished_at" => nil,
        "id"          => request_id,
        "started_at"  => Time.now,
        "successful"  => "true",
        "type"        => "deprovision_environment_variable",
        "resource"    => [:environment_variables, environment_variable_id, lambda do |r|
          environment_variable.merge!("deleted_at" => Time.now)

          self.data[:database_servers].values.
            select { |ds| ds["environment_variable"] == url_for("/environment_variables/#{environment_variable["id"]}") }.
            each { |ds| ds["deleted_at"] = Time.now }

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
