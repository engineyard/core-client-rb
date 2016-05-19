class Ey::Core::Cli::Scp < Ey::Core::Cli::Subcommand
  title "scp"
  summary "This command is deprecated"
  description <<-DESC
    The scp command has been deprecated.  We apologize for any inconvenience.
  DESC

  def handle
    abort "This command is deprecated".red
  end
end
