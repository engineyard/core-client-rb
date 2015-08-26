module ClientHelper
  def create_client(attributes={})
    token = if (user = attributes.delete(:user)) && Ey::Core::Client.mocking?
              core = Ey::Core::Client::Mock.data.values.find { |c| c[:users][user.identity] }
              core[:users][user.identity]["token"]
            end
    token ||= begin
                token_dotfile = YAML.load_file(File.expand_path("/../../../.token"), __FILE__) rescue {}
                ENV["CORE_TOKEN"] || token_dotfile[ENV["CORE_URL"]] || "a4bf6558da8c1051536d1596b8931ebd346aff0b"
              end

    merged_attributes = attributes.merge(token: token, cache: true)
    merged_attributes.merge!(logger: Logger.new(STDOUT)) if ENV['VERBOSE']

    Ey::Core::Client.new(merged_attributes)
  end

  def create_server_client(server, attributes={})
    unless core = Ey::Core::Client::Mock.data.values.find { |data| data[:servers][server.identity] }
      raise "Failed to find server in mock data: #{server}"
    end

    token = core[:servers][server.identity]["token"]

    merged_attributes = attributes.merge(token: token, cache: true)
    merged_attributes.merge!(logger: Logger.new(STDOUT)) if ENV['VERBOSE']

    Ey::Core::Client.new(merged_attributes)
  end

  def create_unauthenticated_client
    Ey::Core::Client.new(token: nil)
  end
end

RSpec.configure do |config|
  config.include(ClientHelper)
end
