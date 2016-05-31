module EnvironmentHelpers
  def known_environments
    begin
      recall_fact(:known_environments)
    rescue
      memorize_fact(:known_environments, [])
    end
  end

  def first_environment
    known_environments.first.reload
  end

  def last_environment
    known_environments.last.reload
  end
end

World(EnvironmentHelpers)
