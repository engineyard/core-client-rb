class Ey::Core::Client::SupportTrial < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :started_at, type: :time
  attribute :expires_at, type: :time

  has_one :account
end
