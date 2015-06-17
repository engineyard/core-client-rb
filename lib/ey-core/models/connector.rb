class Ey::Core::Client::Connector < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :name
  attribute :configuration

  has_one :source, resource: [:cluster_component, :addon, :logical_database], collection: [:cluster_components, :addons, :logical_databases]
  has_one :destination, resource: :cluster_component, collection: :cluster_components

  def save!
    requires :source, :destination

    params = {
      "url"       => self.collection.url,
      "connector" => {
        "source"        => source.identity,
        "destination"   => destination.identity,
        "configuration" => configuration,
      },
    }

    response = if new_record?
                 self.connection.create_connector(params)
               else
                 requires :identity

                 self.connection.update_connector(params.merge("id" => self.identity))
               end

    merge_attributes(response.body["connector"])
  end
end
