module Ey
  module Core
    module Cli
      RecipesNotFound = Class.new(ArgumentError)
      NoCommand       = Class.new(ArgumentError)
      NoRepository    = Class.new(ArgumentError)
      RecipesExist    = Class.new(ArgumentError)
      AmbiguousSearch = Class.new(ArgumentError)
    end
  end
end
