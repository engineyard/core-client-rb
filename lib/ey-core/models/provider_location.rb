class Ey::Core::Client::ProviderLocation < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location_id
  attribute :location_name
  attribute :limits, type: :hash
  attribute :data, type: :hash

  has_many :children, model: :provider_locations
  has_many :compute_flavors
  has_one :provider
  has_one :parent, model: :provider_location

  def save!
    params = {
      "id" => self.id,
      "provider_location" => {
        "limits" => self.limits,
      },
    }

    unless new_record?
      merge_attributes(self.connection.update_provider_location(params).body["provider_location"])
    end
  end
end
