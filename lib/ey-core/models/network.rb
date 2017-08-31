class Ey::Core::Client::Network < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :cidr
  attribute :deleted_at, type: :time
  attribute :location
  attribute :provisioned_id
  attribute :tenancy

  has_one :provider

  attr_accessor :skip_subnets

  def subnets
    connection.subnets.load(connection.get_subnets("network" => self.identity).body["subnets"])
  end

  def save!
    requires :provider_id, :location, :cidr

    params = {
      "url"      => self.collection.url,
      "provider" => self.provider_id,
      "network"  => {
        "cidr"         => self.cidr,
        "location"     => self.location,
        "tenancy"      => self.tenancy || "default",
        "skip_subnets" => self.skip_subnets,
      }
    }

    self.connection.requests.new(self.connection.create_network(params).body["request"])
  end

  def destroy
    requires :identity
    self.connection.requests.new(self.connection.destroy_network("id" => self.identity).body["request"])
  end
end
