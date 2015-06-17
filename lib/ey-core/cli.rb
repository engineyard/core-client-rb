require 'optparse'
require 'ostruct'
require 'ey-core'
require 'awesome_print'

Cistern.formatter = Cistern::Formatter::AwesomePrint

class Ey::Core::Cli

  def self.stdout
    @stdout ||= STDOUT
  end

  def self.say(*args)
    self.stdout.puts(*args)
  end

  attr_reader :options, :action, :resource, :client

  def initialize(args=ARGV)
    @action, @options = parse(args)
  end

  def parse(args)
    options = {}

    action, resource_name, resource_id = OptionParser.new do |opts|
      opts.banner = "Usage: ey-core ACTION RESOURCE RESOURCE_ID [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-t", "--token [TOKEN]",
              "Use specific token. Defaults to core url entry in ~/.ey-core yaml file") do |token|
        options[:token] = token
      end

      opts.on("-u", "--url [URL]",
              "Use specific core URL. Defaults to 'https://api.engineyard.com'") do |url|
        options[:url] = url
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:logger] = v ? Logger.new(STDOUT) : Logger.new(nil)
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts Ey::Core::VERSION
        exit
      end
    end.parse!(args)

    set_client(options)

    set_resource(action, resource_name, resource_id)

    [action, (options.to_hash || {})]
  end

  def run
    public_send(action)
  end

  def show
    Ey::Core::Cli.say(resource.ai)
  end

  def destroy
    response = resource.destroy!

    if response.is_a?(Ey::Core::Client::Request)
      response.wait_for!(response.service.timeout, response.service.poll_interval) do |request|
        Ey::Core::Cli.say "Waiting ... #{Time.now}"
        Ey::Core::Cli.say(response.ai) unless request.ready?
        request.ready?
      end
    end

    Ey::Core::Cli.say(response.ai)
  end

  def set_client(options)
    @client ||= Ey::Core::Client.new(options)
  end

  def set_resource(action, resource_name, resource_id)
    action || raise(ArgumentError.new("Missing action"))
    Ey::Core::Client.models.find { |m,_| m.to_s == resource_name } || raise(ArgumentError.new("Unknown resource: #{resource_name}"))
    %w[show destroy].include?(action) || raise(ArgumentError.new("Unknown action: #{action}"))

    # TODO: irregular inflections and all that
    collection = "#{resource_name.to_s}s"

    @resource = client.public_send(collection).get!(resource_id)
  end
end  # class Ey::Core::Cli
