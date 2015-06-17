class Ey::Core::Client::ApplicationDeployment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :commit
  attribute :created_at, type: :time
  attribute :finished_at, type: :time
  attribute :migrate_command
  attribute :ref
  attribute :serverside_version
  attribute :started_at, type: :time
  attribute :successful, type: :boolean

  has_one :application
  has_one :archive, resource: :application_archive, collection: :application_archives
  has_one :task
end
