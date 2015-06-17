class Ey::Core::Client::Address < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :name
  attribute :ip_address
  attribute :provisioned_id
  attribute :location

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
          "location" => self.location,
        },
      }

      self.connection.requests.new(self.connection.create_address(params).body["request"])
    else raise NotImplementedError
    end
  end
end
