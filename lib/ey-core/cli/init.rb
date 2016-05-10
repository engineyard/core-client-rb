class Ey::Core::Cli::Init < Ey::Core::Cli::Subcommand
  title "init"
  summary "Deprecated"

  def handle
    abort "This command is deprecated".red
  end
end
