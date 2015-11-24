class Ey::Core::Client::Addon < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :vars
  attribute :name
  attribute :sso_url

  has_one  :account

  def resource_url
    "#{collection.url}/#{id}"
  end

  def save!
    params = {
      "addon" => {
        "name" => self.name,
        "vars" => self.vars,
        "sso_url" => self.sso_url,
      },
    }
    if new_record?
      params["url"] = self.collection.url
      merge_attributes(self.connection.create_addon(params).body["addon"])
    else # update
      params["url"] = self.resource_url
      merge_attributes(self.connection.update_addon(params).body["addon"])
    end
  end

  def destroy!
    self.connection.destroy_addon("url" => self.resource_url)
    nil
  end
end
