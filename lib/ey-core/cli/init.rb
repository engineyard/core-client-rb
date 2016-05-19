class Ey::Core::Cli::Init < Ey::Core::Cli::Subcommand
  title "init"
  summary "Deprecated"
  description <<-DESC
   The init command has been deprecated.  We apologize for any inconvenience.
  DESC

  def handle
    abort "This command is deprecated".red
  end
end
