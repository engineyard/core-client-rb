class Ey::Core::Cli::Web < Ey::Core::Cli::Subcommand
  title "web"
  summary "Web related commands"

  Dir[File.dirname(__FILE__) + "/web/*.rb"].each { |file| load file }

  Ey::Core::Cli::Web.descendants.each do |d|
    mount d
  end
end
