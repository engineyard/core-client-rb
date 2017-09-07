class Ey::Core::Client::Subnet < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :cidr
  attribute :location
  attribute :primary, type: :boolean
  attribute :provisioned_id

  has_one :network

  def save!
    requires :network_id, :location, :cidr

    params = {
      "url"     => self.collection.url,
      "network" => self.network_id,
      "subnet"  => {
        "cidr"     => self.cidr,
        "location" => self.location,
      }
    }

    self.connection.requests.new(self.connection.create_subnet(params).body["request"])
  end

  def destroy
    requires :identity
    self.connection.requests.new(self.connection.destroy_subnet("id" => self.identity).body["request"])
  end
end
