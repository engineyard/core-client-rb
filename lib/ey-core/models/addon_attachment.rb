class Ey::Core::Client::AddonAttachment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :string

  attribute :key
  attribute :app_id
  attribute :environment_id
  attribute :suggested_name

  def resource_url
    "#{collection.url}/#{id}"
  end

  def attach!(key)
    self.key = key
    self.save!
  end

  def detach!
    self.key = nil
    self.save!
  end

  def save!
    # always update
    params = {
      "attachment" => {
        "key" => self.key,
      },
      "url" => self.resource_url,
    }
    merge_attributes(self.connection.update_addon_attachment(params).body["addon_attachment"])
  end

end
