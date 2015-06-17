class Ey::Core::Client::Token < Ey::Core::Model

  identity :auth_id

  attribute :on_behalf_of

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
