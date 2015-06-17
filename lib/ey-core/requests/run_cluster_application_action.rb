class Ey::Core::Client
  class Real
    def run_cluster_application_action(params={})
      cluster_id     = params.delete("cluster")
      application_id = params.delete("application")
      action         = params.delete("action")

      request(
        :body   => params,
        :method => :post,
        :path   => "/clusters/#{cluster_id}/applications/#{application_id}/actions/#{action}",
      )
    end
  end # Real

  class Mock
    def run_cluster_application_action(params={})
      cluster_id     = params.delete("cluster")
      application_id = params.delete("application")

      cluster_component = self.data[:cluster_components].values.find { |cc| cc["cluster"] == url_for("/clusters/#{cluster_id}") && cc["configuration"]["application"] == application_id }

      response(status: 404) unless cluster_component

      return run_cluster_component_action(params.merge("cluster_component" => cluster_component["id"]))
    end
  end # Mock
end # Ey::Core::Client
