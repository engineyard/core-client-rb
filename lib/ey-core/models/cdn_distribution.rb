class Ey::Core::Client::CdnDistribution < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :domain
  attribute :aliases, type: :array
  attribute :asset_host_name
  attribute :enabled, type: :boolean
  attribute :origin
  attribute :provisioned_id
  attribute :created_at, type: :time
  attribute :updated_at, type: :time
  attribute :deleted_at, type: :time

  has_one :provider
  has_one :application
  has_one :environment

  def save!
    params = {
      "cdn_distribution" => {
        "aliases"         => self.aliases,
        "asset_host_name" => self.asset_host_name,
        "enabled"         => self.enabled
      }
    }

    if new_record?
      requires :provider_id, :environment_id, :application_id
      params.merge!("url" => self.collection.url, "provider" => self.provider_id, "environment" => self.environment_id,
                    "application" => self.application_id)
      self.connection.requests.new(self.connection.create_cdn_distribution(params).body["request"])
    else
      requires :identity
      params["id"] = self.identity
      params["cdn_distribution"]["origin"] = self.origin
      self.connection.requests.new(self.connection.update_cdn_distribution(params).body["request"])
    end
  end

  def invalidate(paths = ["*"])
    requires :identity
    self.connection.requests.new(self.connection.invalidate_cdn_distribution("id" => self.identity, "paths" => paths).body["request"])
  end

  def destroy
    requires :identity
    self.connection.requests.new(self.connection.destroy_cdn_distribution("id" => self.identity).body["request"])
  end
end
