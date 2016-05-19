class Ey::Core::Cli::Errors
  ::Ey::Core::Cli::RecipesNotFound = Class.new(ArgumentError)
  ::Ey::Core::Cli::NoCommand       = Class.new(ArgumentError)
  ::Ey::Core::Cli::NoRepository    = Class.new(ArgumentError)
  ::Ey::Core::Cli::RecipesExist    = Class.new(ArgumentError)
  ::Ey::Core::Cli::AmbiguousSearch = Class.new(ArgumentError)
end
