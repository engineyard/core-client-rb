class Ey::Core::Client::Environment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :classic, type: :boolean
  attribute :name
  attribute :deleted_at, type: :time
  attribute :monitor_url

  has_one :account
  has_one :project

  has_many :clusters
  has_many :keypairs
  has_many :servers
  has_many :applications
  has_many :logical_databases
  has_many :database_services

  # @param application [Ey::Core::Client::Application]
  # @option opts [Ey::Core::Client::ApplicationArchive] :archive
  def deploy(application, opts={})
    task = opts.dup

    if archive = task.delete(:archive)
      task["archive_id"] = archive.id
    end

    run_action(application, "deploy", task)
  end

  # @param application [Ey::Core::Client::Application]
  # @param action [String]
  # @option opts [Ey::Core::Client::ApplicationArchive] :archive
  def run_action(application, action, task={})
    requires :id

    response = self.connection.run_environment_application_action(
      "environment" => self.id,
      "application" => application.id,
      "task"        => task,
      "action"      => action,
    )
    connection.requests.new(response.body["request"])
  end

  def destroy!
    connection.requests.new(self.connection.destroy_environment("id" => self.id).body["request"])
  end

  def save!
    params = {
      "url"         => self.collection.url,
      "account"     => self.account_id,
      "environment" => {
        "name" => self.name,
      },
    }

    if new_record?
      merge_attributes(self.connection.create_environment(params).body["environment"])
    else raise NotImplementedError # update
    end
  end
end
