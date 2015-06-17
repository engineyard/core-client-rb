class Ey::Core::Client::Task < Ey::Core::Model
  extend Ey::Core::Associations
  include Ey::Core::Subscribable

  identity :id

  attribute :action
  attribute :configuration
  attribute :created_at, type: :time
  attribute :finished_at, type: :time
  attribute :message
  attribute :started_at, type: :time
  attribute :successful, type: :boolean
  attribute :updated_at, type: :time

  has_one :application_deployment
  has_one :schedule

  has_many :component_actions

  def ready?
    !!finished_at
  end

  def save!
    params = {
      "url" => self.collection.url,
    }

    if new_record?
      connection.requests.new(self.connection.create_task(params).body["request"])
    else raise NotImplementedError # update
    end
  end
end
