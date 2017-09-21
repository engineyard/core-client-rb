class Ey::Core::Client
  class Real
    def create_auto_scaling_group(options={})
      url = options.delete("url")

      request(
        :method => :post,
        :url    => url,
        :path   => "/auto_scaling_groups",
        :body   => options
      )
    end
  end

  class Mock
    def create_auto_scaling_group(options={})
      url = options.delete("url")
      environment_id = options.delete("environment")

      environment = find(:environments, environment_id)

      resource_id = self.uuid

      resource = options["auto_scaling_group"].dup

      resource.merge!(
        "created_at"     => Time.now,
        "environment"    => url_for("/environments/#{environment_id}"),
        "id"             => resource_id,
        "location_id"    => environment["region"],
        "provisioned_id" => "#{environment["name"]}#{SecureRandom.uuid}",
        "resource_url"   => url_for("/auto_scaling_groups/#{resource_id}"),
      )

      environment.merge!("auto_scaling_group" => url_for("/auto_scaling_groups/#{resource_id}"))

      request = {
        "created_at"   => Time.now,
        "finished_at"  => nil,
        "id"           => self.uuid,
        "message"      => nil,
        "read_channel" => nil,
        "resource"     => [:auto_scaling_groups, resource_id, resource],
        "resource_url" => url_for("/auto_scaling_groups/#{resource_id}"),
        "started_at"   => Time.now,
        "successful"   => true,
        "type"         => "provision_auto_scaling_group",
        "updated_at"   => Time.now,
      }

      self.data[:requests][request["id"]] = request

      response(
        :body   => {"request" => request},
        :status => 201
      )
    end
  end
end
