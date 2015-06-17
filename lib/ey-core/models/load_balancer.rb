class Ey::Core::Client::LoadBalancer < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :dns_name
  attribute :deleted_at, type: :time

  attribute :provisioner_id
  attribute :location

  has_many :load_balancer_services, aliases: "services"

  has_one :provider
  has_one :firewall

  def services
    load_balancer_services
  end

  def save!
    requires :provider_id, :name

    params = {
        "url" => self.collection.url,
        "provider" => self.provider_id,
        "load_balancer" => {
          "location" => self.location,
          "name" => self.name
        },
    }

    if new_record?
      self.connection.requests.new(self.connection.create_load_balancer(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_load_balancer("id" => self.id).body["request"])
  end
end
