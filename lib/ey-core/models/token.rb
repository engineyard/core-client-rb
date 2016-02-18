class Ey::Core::Client::Token < Ey::Core::Model

  identity :id

  attribute :auth_id
  attribute :on_behalf_of
  attribute :last_seen_at, type: :time
  attribute :expires_at,   type: :time
  attribute :revoked_at,   type: :time

  def save!
    params = {
      "on_behalf_of" => {
        "id"   => self.on_behalf_of.id,
        "type" => self.on_behalf_of.class.api_name,
      }
    }
    if new_record?
      merge_attributes(self.connection.create_token(params).body["token"])
    else raise NotImplementedError # update
    end
  end

end
