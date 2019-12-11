require 'yaml'

module ConfigFileHelpers
  def config_file_location
    File.expand_path(File.join(aruba.current_directory, '.ey-core'))
  end

  def write_config_file(hash = {})
    c = File.open(config_file_location, 'w')
    c.write(hash.to_yaml)
    c.close
  end

  def read_config_file
    begin
      YAML.load_file(File.read(config_file_location))
    rescue
      {}
    end
  end

  def nuke_config_file
    FileUtils.rm_f(config_file_location) if File.exist?(config_file_location)
  end

  def add_config_option(hash = {})
    current = read_config_file
    write_config_file(current.merge(hash))
  end

  def remove_config_option(key)
    current = read_config_file
    current.delete(key)
    write_config_file(current)
  end
end

World(ConfigFileHelpers)

After do
  nuke_config_file
end
