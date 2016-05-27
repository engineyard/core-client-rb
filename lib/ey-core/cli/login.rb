class Ey::Core::Cli::Login < Ey::Core::Cli::Subcommand
  title "login"
  summary "Retrieve API token from Engine Yard Cloud"

  def handle
    email    = ENV["EMAIL"]    || ask("Email: ")
    password = ENV["PASSWORD"] || ask("Password: ") { |q| q.echo = false }

    token = unauthenticated_core_client.get_api_token(email, password).body["api_token"]

    existing_token = core_yaml[core_url]
    write_token    = if existing_token && existing_token != token
                       puts "New token does not match existing token.  Overwriting".yellow
                       true
                     elsif existing_token == token
                       puts "Token already exists".green
                       false
                     else
                       puts "Writing token".green
                       true
                     end
    write_core_yaml(token) if write_token
  rescue Ey::Core::Response::Unauthorized
    abort "Invalid email or password".yellow
  end
end
