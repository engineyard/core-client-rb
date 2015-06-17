class Ey::Core::Client::Firewall < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :name
  attribute :provisioned_id
  attribute :deleted_at, type: :time

  has_one :provider

  has_many :clusters
  has_many :firewall_rules, aliases: "rules"

  def rules
    firewall_rules
  end


  attr_accessor :cluster

  def save!
    requires :name, :provider_id

    params = {
      "url"      => self.collection.url,
      "firewall" => {
        "name"     => self.name,
        "location" => self.location,
      },
      "cluster"  => self.cluster,
      "provider" => self.provider_id,
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
