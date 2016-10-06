class Ey::Core::Client::ProviderLocation < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location_id
  attribute :location_name
  attribute :limits, type: :hash

  has_one :provider

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
