class Ey::Core::Client::Address < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :name
  attribute :ip_address
  attribute :provisioned_id
  attribute :location
  attribute :disappeared_at, type: :time

  has_one :provider
  has_one :server

  def detach
    params = {
      "id" => self.identity,
    }

    self.connection.requests.new(self.connection.detach_address(params).body["request"])
  end

  def attach(server)
    params = {
      "id"     => self.identity,
      "server" => server.identity,
    }

    self.connection.requests.new(self.connection.attach_address(params).body["request"])
  end

  def save!
    if new_record?
      requires :provider_id, :location

      params = {
        "provider" => self.provider_id,
        "address"  => {
          "location"       => self.location,
          "provisioned_id" => self.provisioned_id
        },
      }

      self.connection.requests.new(self.connection.create_address(params).body["request"])
    else
      requires :identity

      params = {
        "id" => self.identity,
        "address" => {
          "disappeared_at" => self.disappeared_at,
        }
      }

      merge_attributes(self.connection.update_address(params).body["address"])
    end
  end
end
