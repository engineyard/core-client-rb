class Ey::Core::Client
  class Real
    def create_backup_file(params={})
      id  = params["id"]
      url = params["url"]

      request(
        :method => :post,
        :path   => "backup_files/#{id}",
        :url    => url,
        :body   => params,
      )
    end
  end # Real

  class Mock
    def create_backup_file(params={})
      resource_id = self.uuid

      unless resource = params["backup_file"].dup
        response(status: 422)
      end

      unless filename = resource["filename"]
        response(status: 422, body: {"error" => ["Missing required attribute: filename"]})
      end

      backup_id = params["url"].split("/")[-2]

      uuid = self.uuid

      resource.merge!(
        "id"           => resource_id,
        "files"        => url_for("/backup_files/#{resource_id}/files"),
        "mime_type"    => resource["mime_type"] || MIME::Types.type_for(filename).first.to_s,
        # these need to be the same for mocking purposes
        "download_url" => "http://example.org/#{uuid}",
        "upload_url"   => "http://example.org/#{uuid}",
        "backup"       => url_for("/backups/#{backup_id}"),
        "created_at"   => Time.now,
        "updated_at"   => Time.now,
      )

      self.data[:backup_files][resource_id] = resource

      response(
        :body   => {"backup_file" => resource},
        :status => 201,
      )
    end
  end # Mock
end # Ey::Core::Client
