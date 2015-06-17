class Ey::Core::Client
  class Real
    def create_backup(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :post,
        :path   => "backups/#{id}",
        :url    => url,
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_backup(params={})
      resource_id = self.uuid

      cluster_id = if params["url"] # provided scope
                     path_params(params["url"])["clusters"]
                   elsif current_server
                     path_params(current_server["cluster"])["clusters"]
                   end
      find(:clusters, cluster_id)


      resource = params["backup"].dup

      resource.merge!(
        "id"         => resource_id,
        "files"      => url_for("/backups/#{resource_id}/files"),
        "cluster"    => url_for("/clusters/#{cluster_id}"),
        "created_at" => Time.now,
        "updated_at" => Time.now,
      )

      self.data[:backups][resource_id] = resource

      response(
        :body   => {"backup" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
