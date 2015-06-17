class Ey::Core::Client::UntrackedServer < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :provisioned_id
  attribute :provisioner_id
  attribute :location
  attribute :state
  attribute :created_at, type: :time
  attribute :updated_at, type: :time

  has_one :provider

  def save!
    request_attributes = {
      "provider" => self.provider_id,
      "url"      => self.collection.url,
    }

    response = if new_record?
                 requires :location, :provisioned_id

                 request_attributes.merge!(
                   "untracked_server" => Cistern::Hash.slice(
                     Cistern::Hash.stringify_keys(self.attributes), "location", "provisioned_id", "provisioner_id", "state"
                   ),
                 )

                 connection.create_untracked_server(request_attributes)
               else
                 requires :identity

                 request_attributes.merge!(
                   "untracked_server" => Cistern::Hash.slice(
                     Cistern::Hash.stringify_keys(self.attributes), "location", "provisioner_id", "state"
                   ),
                 )

                 connection.update_untracked_server(request_attributes.merge("id" => self.identity))
               end

    merge_attributes(response.body["untracked_server"])
  end
end
