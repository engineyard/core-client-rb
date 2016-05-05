class Ey::Core::Client::Blueprint < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :data, type: :hash
  attribute :name
  attribute :created_at, type: :time
  attribute :updated_at, type: :time

  has_one :account
  has_one :environment

  def save!
    requires :id

    params = {
      "id"        => self.id,
      "blueprint" => {
        "name" => self.name
      }
    }

    merge_attributes(self.connection.update_blueprint(params).body["blueprint"])
  end

  def destroy
    self.connection.destroy_blueprint("id" => self.identity)
  end
end
