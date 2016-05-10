class Ey::Core::Cli::CurrentUser < Ey::Core::Cli::Subcommand
  title "current_user"
  summary "Print the current user information"

  def handle
    ap core_client.users.current
  end
end
