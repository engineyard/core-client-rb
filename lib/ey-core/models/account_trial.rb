class Ey::Core::Client::AccountTrial < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id, type: :integer

  attribute :duration, type: :integer
  attribute :used, type: :integer
  attribute :period_remaining

  attribute :started_at, type: :time
  attribute :finished_at, type: :time
  attribute :converted_at, type: :time

  has_one :account
end
