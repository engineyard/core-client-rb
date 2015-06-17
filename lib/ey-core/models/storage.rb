class Ey::Core::Client::Storage < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :location
  attribute :provisioned_id

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time

  has_one :provider

  has_many :storage_users, aliases: "users"

  def save!
    requires :provider_id, :name, :location

    params = {
        "url" => self.collection.url,
        "provider" => self.provider_id,
        "storage" => {
          "location" => self.location,
          "name" => self.name
        },
    }

    if new_record?
      self.connection.requests.new(self.connection.create_storage(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    connection.requests.new(connection.destroy_storage(id).body["request"])
  end
end
