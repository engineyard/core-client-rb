class Ey::Core::Client::Firewall < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :name
  attribute :provisioned_id
  attribute :deleted_at, type: :time

  has_one :provider
  has_one :environment

  has_many :firewall_rules, aliases: "rules"

  def rules
    firewall_rules
  end

  attr_accessor :cluster

  def save!
    raise "Not implemented"

    # Todo: this is not currently supported in the API
    requires :name, :provider_id, :environment_id

    params = {
      "url"      => self.collection.url,
      "firewall" => {
        "name"     => self.name,
      },
      "environment" => self.environment,
      "provider"    => self.provider_id,
    }

    if new_record?
      self.connection.requests.new(self.connection.create_firewall(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_firewall("id" => self.id).body["request"])
  end
end
