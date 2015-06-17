class Ey::Core::Client
  class Real
    # Create a log.
    #
    # params - A  hash of log params:
    #   component_action_id - A component action id (required).
    #   log - A hash of log attributes:
    #     file - File body.
    #     filename - The name of the log file.
    #     mime_type - The file mime type.
    #
    # Returns the created log.
    def create_log(params={})
      query_params = {"log" => params["log"]}
      component_action_id = params["component_action_id"]
      body = query_params.to_json

      request(
        :method => :post,
        :path   => "/component-actions/#{component_action_id}/logs",
        :body => body
      )
    end
  end # Real

  class Mock
    def create_log(params={})
      log_id = self.uuid
      log_params = params["log"]

      filename = log_params["filename"]

      log = {
        "id"               => log_id,
        "filename"         => filename,
        "download_url"     => "http://s3.amazon.com/#{filename}",
        "uplaod_url"       => nil,
        "created_at"       => Time.now,
        "updated_at"       => Time.now,
        "deleted_at"       => nil,
        "mime_type"        => params[:mime_type] || "application/json",
        "component_action" => nil, # @fixme support genuine component actions
        "server"           => params["server"],
      }

      self.data[:logs][log_id] = log
      response(
        :body => {"log" => log},
        :status => 201
      )
    end
  end # Mock
end
