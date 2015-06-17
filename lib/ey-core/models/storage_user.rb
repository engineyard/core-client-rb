class Ey::Core::Client::StorageUser < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :username
  attribute :access_id
  attribute :secret_key
  attribute :provisioned_id

  attribute :created_at, type: :time
  attribute :deleted_at, type: :time

  has_one :storage

  attr_accessor :permissions

  def save!
    requires :storage_id, :username

    params = {
        "url"          => self.collection.url,
        "storage"      => self.storage_id,
        "storage_user" => {
          "username"    => self.username,
          "permissions" => self.permissions
        },
    }

    if new_record?
      self.connection.requests.new(self.connection.create_storage_user(params).body["request"])
    else raise NotImplementedError
    end
  end

  def destroy!
    requires :identity

    params = {
      "id" => self.identity,
    }
    connection.requests.new(connection.destroy_storage_user(params).body["request"])
  end
end
