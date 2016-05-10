class Ey::Core::Cli::Version < Ey::Core::Cli::Subcommand
  title "version"
  summary "Print the version of the gem"

  def handle
    puts Ey::Core::VERSION
  end
end
