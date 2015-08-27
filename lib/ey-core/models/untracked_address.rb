class Ey::Core::Client::UntrackedAddress < Ey::Core::Model
  extend Ey::Core::Associations

  attribute :provisioned_id
  attribute :provisioner_id
  attribute :location

  has_one :provider
  has_one :address

  def save!
    request_attributes = {
      "provider" => self.provider_id,
      "url"      => self.collection.url,
      "address"  => {
        "location" => self.location,
        "provisioned_id" => self.provisioned_id,
        "provisioner_id" => self.provisioner_id,
      }
    }

    merge_attributes(connection.create_untracked_address(request_attributes).body["untracked_address"])
  end
end
