class Ey::Core::Client::DatabaseServerSnapshot < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :deleted_at,     type: :time
  attribute :engine
  attribute :engine_version
  attribute :location
  attribute :provisioned_at, type: :time
  attribute :provisioned_id
  attribute :storage,        type: :integer

  has_one :provider
  has_one :database_server
  has_one :database_service

  attr_accessor :name

  def save
    if new_record?
      create_params = if collection.url
                        { "url" => collection.url }
                      elsif self.database_service
                        { "database_service" => self.database_service.identity }
                      else
                        requires_one :database_server, :database_service

                        { "database_service" => self.database_server.database_service.identity }
                      end

      connection.requests.new(
        connection.create_database_service_snapshot(create_params.merge("name" => self.name)).body["request"]
      )
    end
  end
end
