class Ey::Core::Client::FirewallRule < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :port_range, parser: lambda { |v,_| range_parser(v) }
  attribute :source, type: :string
  attribute :deleted_at, type: :time

  has_one :firewall

  def source_firewall
    unless source.match(Ey::Core::IP_REGEX)
      self.connection.firewalls.get(self.source)
    end
  end

  def save!
    requires :firewall_id

    self.port_range ||= "0-65535"

    params = {
      "url"           => self.collection.url,
      "firewall_rule" => {
        "port_range" => "#{self.port_range.min}-#{self.port_range.max}",
        "source"     => self.source     || "0.0.0.0/0",
      },
      "firewall" => self.firewall_id,
    }

    if new_record?
      self.connection.requests.new(self.connection.create_firewall_rule(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(self.connection.destroy_firewall_rule("id" => self.id).body["request"])
  end
end
