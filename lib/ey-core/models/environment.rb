class Ey::Core::Client::Environment < Ey::Core::Model
  extend Ey::Core::Associations

  identity :id

  attribute :classic, type: :boolean
  attribute :created_at, type: :time
  attribute :custom_recipes
  attribute :database_stack
  attribute :deleted_at, type: :time
  attribute :deploy_method
  attribute :framework_env
  attribute :language
  attribute :monitor_url
  attribute :name
  attribute :region
  attribute :release_label
  attribute :stack_name
  attribute :username
  attribute :service_level
  attribute :database_backup_limit
  attribute :encrypted_ebs_for_everything

  has_one :account
  has_one :database_service
  has_one :firewall
  has_one :auto_scaling_group
  has_one :assignee, assoc_name: :user, resource: :user

  has_many :costs
  has_many :keypairs
  has_many :servers
  has_many :applications
  has_many :logical_databases
  has_many :deployments
  has_many :cdn_distributions

  attr_accessor :application_id

  def latest_deploy(app)
    deployments = connection.deployments.all(environment_id: self.id, application_id: app.id)
    deployments.first
  end

  # @param application [Ey::Core::Client::Application]
  # @option opts [Ey::Core::Client::ApplicationArchive] :archive
  def deploy(application, opts={})
    raise "Environment does not contain an app deployment for this application" unless self.applications.get(application.id)
    raise ":ref is a required key" unless opts[:ref]
    connection.requests.new(connection.deploy_environment_application({"deploy" => opts}.merge("id" => self.id, "application_id" => application.id)).body["request"])
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

  def apply(type="main", data={})
    connection.requests.new(self.connection.apply_environment_updates("id" => self.id, "type" => type, "data" => data).body["request"])
  end

  def deprovision
    connection.requests.new(self.connection.deprovision_environment("id" => self.id).body["request"])
  end

  def destroy!
    connection.requests.new(self.connection.destroy_environment("id" => self.id).body["request"])
  end

  def application
    if self.application_id
      connection.applications.get(self.application_id)
    end
  end

  def blueprints
    requires :id
    self.connection.blueprints.all(environment: self.identity)
  end

  def save_blueprint(options={})
    requires :id
    raise "name is a required key" unless options["name"]
    self.connection.blueprints.new(self.connection.blueprint_environment("id" => self.id, "name" => options["name"]).body["blueprint"])
  end

  def upload_recipes(file)
    # file should be a StringIO
    self.connection.upload_recipes_for_environment("file" => file, "id" => self.identity)
  end

  def maintenance(application, action)
    requires :identity

    params = {
      "id"             => self.identity,
      "application_id" => application.id,
      "maintenance"    => {
        "action" => action
      }
    }

    self.connection.requests.new(self.connection.change_environment_maintenance(params).body["request"])
  end

  def restart_app_servers
    params = {
      "id"             => self.identity,
      "application_id" => self.applications.first.id,
    }

    self.connection.requests.new(self.connection.restart_environment_app_servers(params).body["request"])
  end

  def download_recipes
    tempfile = Tempfile.new("cookbooks-#{self.name}.tar.gz")
    File.open(tempfile, 'wb') { |f| f.write self.connection.request(url: self.custom_recipes).body }
    tempfile
  end

  def boot(options={})
    options = Cistern::Hash.stringify_keys(options)
    if options["blueprint_id"]
      params = {
        "cluster_configuration" => {
          "blueprint_id" => options["blueprint_id"],
          "configuration" => {}
        }
      }
      if ip_id = options["ip_id"]
        params["cluster_configuration"]["configuration"]["ip_id"] = ip_id
      end

      self.connection.requests.new(self.connection.boot_environment(params.merge("id" => self.id)).body["request"])
    else
      raise "configuration is a required key" unless options["configuration"]
      raise "configuration['type'] is required" unless options["configuration"]["type"]

      missing_keys = []

      configuration = options["configuration"]
      required_keys = %w(flavor volume_size mnt_volume_size)

      if self.database_service
        raise "application_id is a required key" unless options["application_id"]

        configuration["logical_database"] = "#{self.name}_#{self.application.name}"
      end

      if configuration["type"] == 'custom'
        apps      = configuration["apps"]      ||= {}
        db_master = configuration["db_master"] ||= {}
        db_slaves = configuration["db_slaves"] ||= []
        utils     = configuration["utils"]     ||= []

        missing_keys << "apps" unless apps.any?
        (required_keys + ["count"]).each do |required|
          missing_keys << "apps[#{required}]" unless apps[required]
        end

        unless configuration["database_service_id"]
          missing_keys << "db_master" unless db_master.any?

          required_keys.each do |key|
            missing_keys << "db_master[#{key}]" unless db_master[key]
          end
        end

        db_slaves.each_with_index do |slave, i|
          (required_keys - ["volume_size", "mnt_volume_size"]).each do |key|
            missing_keys << "db_slaves[#{i}][#{key}]" unless slave[key]
          end
        end

        utils.each_with_index do |util, i|
          required_keys.each do |key|
            missing_keys << "utils[#{i}][#{key}]" unless util[key]
          end
        end
      end

      if missing_keys.any?
        raise "Invalid configuration - The following keys are missing from the configuration:\n#{missing_keys.join(",\n")}"
      end

      params = {
        "cluster_configuration" => {
          "configuration" => configuration
        }
      }

      connection.requests.new(self.connection.boot_environment(params.merge("id" => self.id)).body["request"])
    end
  end

  def unassign!
    requires :id
    merge_attributes(self.connection.unassign_environment("id" => self.id).body["environment"])
  end

  def save!
    if new_record?
      requires :application_id, :account_id, :region

      params = {
        "url"         => self.collection.url,
        "account"     => self.account_id,
        "environment" => {
          "name"                         => self.name,
          "application_id"               => self.application_id,
          "region"                       => self.region,
          "stack_name"                   => self.stack_name,
          "database_stack"               => self.database_stack,
          "release_label"                => self.release_label,
          "language"                     => self.language,
          "database_backup_limit"        => self.database_backup_limit,
          "encrypted_ebs_for_everything" => self.encrypted_ebs_for_everything,
        },
      }

      params["environment"].merge!("database_service" => self.database_service.id) if self.database_service

      merge_attributes(self.connection.create_environment(params).body["environment"])
    else
      requires :identity
      attributes = Cistern::Hash.slice(Cistern::Hash.stringify_keys(self.attributes), "nane", "release_label")
      connection.update_environment(
        "id"     => self.identity,
        "environment" => attributes,
      )
    end
  end
end
