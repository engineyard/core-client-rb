class Ey::Core::Client::Deployment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :commit
  attribute :finished_at,    type: :time
  attribute :migrate,        type: :boolean
  attribute :migrate_command
  attribute :ref
  attribute :resolved_ref
  attribute :serverside_version
  attribute :started_at,     type: :time
  attribute :successful,     type: :boolean
  attribute :verbose
  attribute :streaming
  attribute :request_url, aliases: :request

  has_one :account
  has_one :environment
  has_one :application
  has_one :user

  def request
    self.request_url && self.connection.requests.get(self.request_url.split("/").last)
  end

  def timeout(message=nil)
    merge_attributes(self.connection.timeout_deployment("id" => self.id, "message" => message).body["deployment"])
  end
end
