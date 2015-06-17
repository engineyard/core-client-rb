class Ey::Core::Client::Cluster < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :location
  attribute :name
  attribute :configuration
  attribute :deleted_at, type: :time

  attribute :release_label

  has_one :environment
  has_one :provider

  has_many :backups
  has_many :cluster_components, aliases: "components"
  has_many :firewalls
  has_many :servers
  has_many :slots
  has_many :cluster_updates, aliases: "updates"

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

    response = self.connection.run_cluster_application_action(
      "cluster"     => self.id,
      "application" => application.id,
      "task"        => task,
      "action"      => action,
    )
    connection.requests.new(response.body["request"])
  end

  def save!
    if new_record?
      requires :name, :location, :provider_id
      params = {
        "cluster" => {
          "location"      => self.location,
          "name"          => self.name,
          "provider"      => self.provider_id,
          "release_label" => self.release_label,
          "configuration" => self.configuration,
        },
        "environment" => self.environment_id,
        "url"         => self.collection.url,
      }
      merge_attributes(self.connection.create_cluster(params).body["cluster"])
    else
      params = {
        "id" => id,
        "cluster" => {
          "release_label" => self.release_label,
          "configuration" => self.configuration,
        }
      }
      merge_attributes(self.connection.update_cluster(params).body["cluster"])
    end
  end

  def destroy!
    connection.requests.new(connection.destroy_cluster(id).body["request"])
  end
end
