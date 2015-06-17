class Ey::Core::Client::DatabaseServerRevision < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :revision_time, type: :time
  attribute :data,          type: :hash

  has_one :database_server
end
