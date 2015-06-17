class Ey::Core::Client::ComponentAction < Ey::Core::Model
  extend Ey::Core::Associations
  include Ey::Core::Subscribable

  identity :id

  attribute :command
  attribute :exit_code, type: :integer
  attribute :message
  attribute :name
  attribute :successful, type: :boolean
  attribute :uri

  attribute :created_at, type: :time
  attribute :finished_at, type: :time
  attribute :started_at, type: :time
  attribute :updated_at, type: :time

  has_one :account
  has_one :requester, resource: :request
  has_one :task

  has_many :dependencies, key: :request
  has_many :logs

  def ready?
    !!finished_at
  end
end
