class Ey::Core::Client::Subnet < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :cidr
  attribute :location_id
  attribute :provisioned_id

  has_one :network

  def save!
    requires :network_id, :location_id, :cidr

    params = {
      "url"      => self.collection.url,
      "provider" => self.network,
      "network"  => {
        "cidr"        => self.cidr,
        "location_id" => self.location_id,
      }
    }

    self.connection.requests.new(self.connection.create_subnet(params).body["request"])
  end

  def destroy
    requires :identity
    self.connection.requests.new(self.connection.destroy_subnet("id" => self.identity).body["request"])
  end
end
