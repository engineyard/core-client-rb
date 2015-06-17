class Ey::Core::Client::Billing < Ey::Core::Model
  identity :id
  attribute :state

  def new(attributes = {})
    self.class.new(attributes.merge(:connection => self.connection))
  end

  def put_state(id, state)
    b = self.class.new(:connection => self.connection)
    b.id = id
    b.state = state
    b.save!
  end

  def save!
    params = {
      "id"    => self.id,
      "state" => self.state
    }
    merge_attributes(self.connection.update_billing(params).body["billing"])
  end

  def get(params)
    merge_attributes(connection.get_billing(params).body["billing"])
  end
end
