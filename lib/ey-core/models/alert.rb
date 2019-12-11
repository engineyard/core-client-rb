class Ey::Core::Client::Alert < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :acknowledged, type: :boolean
  attribute :created_at, type: :time
  attribute :description
  attribute :external_id
  attribute :finished_at, type: :time
  attribute :ignored, type: :boolean
  attribute :message
  attribute :name
  attribute :resource_url, aliases: "resource"
  attribute :severity
  attribute :started_at, type: :time
  attribute :updated_at, type: :time

  attr_writer :database_server, :server, :agent, :resource

  def resource
    type, identity = resource_keys

    self.connection.public_send(type.gsub("-", "_")).get!(identity)
  end

  def resource_keys
    requires :resource_url

    resource_url.split("/")[-2..-1]
  end

  def server
    type, identity = resource_keys

    (type == "servers" || nil) && self.connection.servers.get!(identity)
  end

  def agent
    type, identity = resource_keys

    (type == "agents" || nil) && self.connection.agents.get!(identity)
  end

  def database_server
    type, identity = resource_keys

    (type == "database-servers" || nil) && self.connection.database_servers.get!(identity)
  end

  def acknowledge!
    requires :id
    merge_attributes(self.connection.acknowledge_alert("id" => self.id).body["legacy_alert"])
  end

  def save!
    response = if new_record?
                 params = {
                   "url"   => self.collection.url,
                   "alert" => {
                     "description" => description,
                     "external_id" => external_id,
                     "finished_at" => finished_at,
                     "message"     => message,
                     "name"        => name,
                     "severity"    => severity,
                     "started_at"  => started_at,
                   }
                 }

                 if @database_server
                   params.merge!(database_server_id: @database_server.identity)
                 elsif @server
                   params.merge!(server_id: @server.identity)
                 end

                 self.connection.create_alert(params)
               else
                 requires :identity

                 params = {
                   :id    => self.id,
                   :alert => {
                     :acknowledged => acknowledged,
                     :external_id  => external_id,
                     :finished_at  => finished_at,
                     :ignored      => ignored,
                     :message      => message,
                     :severity     => severity,
                     :started_at   => started_at
                   }
                 }

                 self.connection.update_alert(params)
               end

    merge_attributes(response.body["alert"])
  end
end
