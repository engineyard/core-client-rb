class Ey::Core::Cli::Subcommand < Belafonte::App
  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  class << self
    attr_accessor :core_file

    def core_file
      @core_file ||= File.expand_path("~/.ey-core")
    end

    def eyrc
      @eyrc ||= File.expand_path("~/.eyrc")
    end
  end

  def unauthenticated_core_client
    @unauthenticated_core_client ||= Ey::Core::Client.new(token: nil, url: core_url)
  end

  def core_client
    @core_client ||= Ey::Core::Client.new(url: core_url, config_file: self.class.core_file)
  rescue RuntimeError => e
    if legacy_token = e.message.match(/missing token/i) && eyrc_yaml["api_token"]
      puts "Found legacy .eyrc token.  Migrating to core file".green
      write_core_yaml(legacy_token)
      retry
    elsif e.message.match(/missing token/i)
      abort "Missing credentials: Run 'ey login' to retrieve your Engine Yard Cloud API token.".yellow
    else
      raise e
    end
  end

  def core_url
    env_url = ENV["CORE_URL"] || ENV["CLOUD_URL"]
    (env_url && File.join(env_url, '/')) || "https://api.engineyard.com/"
  end

  def current_accounts
    core_client.users.current.accounts
  end

  def longest_length_by_name(collection)
    collection.map(&:name).group_by(&:size).max.last.length
  end

  def write_core_yaml(token=nil)
    core_yaml[core_url] = token if token
    File.open(self.class.core_file, "w") { |f| f.puts core_yaml.to_yaml }
  end

  def eyrc_yaml
    @eyrc_yaml ||= YAML.load_file(self.class.eyrc) || {}
  rescue Errno::ENOENT => e # we don't really care if this doesn't exist
    {}
  end

  def core_yaml
    @core_yaml ||= YAML.load_file(self.class.core_file) || {}
  rescue Errno::ENOENT => e
    puts "Creating #{self.class.core_file}".yellow
    FileUtils.touch(self.class.core_file)
    retry
  end

  def core_account_for(options={})
    @core_account ||= core_client.accounts.get(options[:account])
    @core_account ||= core_client.users.current.accounts.first(name: options[:account])
  end

  def operator(options)
    options[:account] ? core_account_for(options) : core_client
  end

  def core_operator_and_environment_for(options={})
    unless options[:environment]
      raise "--environment is required (for a list of environments, try `ey environments`)"
    end
    operator = operator(options)
    environment = operator.environments.get(options[:environment]) || operator.environments.first(name: options[:environment])
    unless environment
      raise "environment '#{options[:environment]}' not found (for a list of environments, try `ey environments`)"
    end
    [operator, environment]
  end

  def core_environment_for(options={})
    core_client.environments.get(options[:environment]) || core_client.environments.first(name: options[:environment])
  end

  def core_server_for(options={})
    operator = options.fetch(:operator, core_client)
    operator.servers.get(options[:server]) || operator.servers.first(provisioned_id: options[:server])
  end

  def core_application_for(environment, options={})
    candidate_apps = nil
    unless options[:app]
      candidate_apps = environment.applications.map(&:name)
      if candidate_apps.size == 1
        options[:app] = candidate_apps.first
      else
        raise "--app is required (Candidate apps on environment #{environment.name}: #{candidate_apps.join(', ')})"
      end
    end

    app = begin
            Integer(options[:app])
          rescue
            options[:app]
          end

    if app.is_a?(Integer)
      environment.applications.get(app)
    else
      applications = environment.applications.all(name: app)
      if applications.count == 1
        applications.first
      else
        error_msg = [
          "Found multiple applications that matched that search.",
          "Please be more specific by specifying the account, environment, and application name.",
          "Matching applications: #{applications.map(&:name)}.",
        ]
        if candidate_apps
          error_msg << "applications on this environment: #{candidate_apps}"
        end
        raise Ey::Core::Cli::AmbiguousSearch.new(error_msg.join(" "))
      end
    end
  end

  def run_handle
    super
  rescue Ey::Core::Response::Error => e
    if ENV["DEBUG"]
      puts e.inspect
      puts e.backtrace
    end
    handle_core_error(e)
  rescue => e
    if ENV["DEBUG"]
      puts e.inspect
      puts e.backtrace
    end
    raise e
  end

  #TODO: a lot more errors that would could handle with nice messages, eventually this should probably be it's own class
  def handle_core_error(e)
    stderr.puts "Error: #{e.error_type}".red
    (e.response.body["errors"] || [e.message]).each do |message|
      stderr.puts Wrapomatic.wrap(message, indents: 1)
    end
    if e.is_a?(Ey::Core::Response::Unauthorized)
      stderr.puts "Check the contents of ~/.ey-core vs https://cloud.engineyard.com/cli"
    end
    raise SystemExit.new(255)
  end

end
