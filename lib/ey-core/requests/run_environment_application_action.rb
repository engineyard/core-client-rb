class Ey::Core::Client
  class Real
    def run_environment_application_action(params={})
      environment_id = params.delete("environment")
      application_id = params.delete("application")
      action         = params.delete("action")

      request(
        :body   => params,
        :method => :post,
        :path   => "/environments/#{environment_id}/applications/#{application_id}/actions/#{action}"
      )
    end
  end # Real

  class Mock
    def run_environment_application_action(params={})
      environment_id = params.delete('environment')
      application_id = params.delete('application')

      clusters = self.data[:clusters].select { |k,c| c['environment'] == url_for("/environments/#{environment_id}") }
      cluster_urls = clusters.keys.map { |k| url_for("/clusters/#{k}") }
      cluster_components = self.data[:cluster_components].values.select { |cc| cluster_urls.include?(cc["cluster"]) && cc["configuration"]["application"] == application_id }

      response(status: 404) unless cluster_components
      cluster_components.map { |cc| run_cluster_component_action(params.merge("cluster_component" => cc["id"])) }.first
    end
  end # Mock
end # Ey::Core::Client
