module EnvironmentVariableHelpers
  ENVIRONMENT_VARIABLE_DISPLAY_FIELDS = %i[id name value environment_name application_name]

  def known_environment_variables
    begin
      recall_fact(:environment_variables)
    rescue
      memorize_fact(:environment_variables, [])
    end
  end

  def match_environment_variable_regexp(environment_variable)
    regexp_parts = ENVIRONMENT_VARIABLE_DISPLAY_FIELDS.map do |field|
      Regexp.escape(environment_variable.send(field).to_s)
    end
    Regexp.new(regexp_parts.join("(\s+)\\|(\s+)"))
  end
end

World(EnvironmentVariableHelpers)
