class Ey::Core::Client::SessionToken < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :on_behalf_of
  attribute :session_id
  attribute :expires_at
  attribute :redirect_url
  attribute :upgrade_url

  def save!
    requires :on_behalf_of, :redirect_url

    params = {
      "on_behalf_of" => self.on_behalf_of.id,
      "redirect_url" => self.redirect_url,
    }
    if new_record?
      merge_attributes(self.connection.create_session_token(params).body["session_token"])
    else raise NotImplementedError # update
    end
  end
end
