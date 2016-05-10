class Ey::Core::Cli::Recipes < Ey::Core::Cli::Subcommand
  title "recipes"
  summary "Chef specific commands"

  Dir[File.dirname(__FILE__) + "/recipes/*.rb"].each { |file| load file }

  Ey::Core::Cli::Recipes.descendants.each do |d|
    mount d
  end

  def run_chef(type, environment)
    request = environment.apply(type)
    puts "Started #{type} chef run".green
    request.wait_for { |r| r.ready? }
    if request.successful
      puts "#{type.capitalize} chef run completed".green
    else
      puts "#{type.capitalize} chef run failed".red
      ap request
    end
  end

  def gzip(tarfile)
    gz = StringIO.new("")
    z = Zlib::GzipWriter.new(gz)
    z.write tarfile.string
    z.close # this is necessary!

    # z was closed to write the gzip footer, so
    # now we need a new StringIO
    StringIO.new gz.string
  end

  def archive_directory(path)
    tarfile = StringIO.new("")
    Gem::Package::TarWriter.new(tarfile) do |tar|
      Dir[File.join(path, "**/*")].each do |file|
        mode          = File.stat(file).mode
        relative_file = "cookbooks/#{file.sub(/^#{Regexp::escape path}\/?/, '')}"

        if File.directory?(file)
          tar.mkdir relative_file, mode
        else
          tar.add_file relative_file, mode do |tf|
            File.open(file, "rb") { |f| tf.write f.read }
          end
        end
      end
    end

    tarfile.rewind
    gzip(tarfile)
  end

  def upload_recipes(environment, path="cookbooks/")
    recipes_path = Pathname.new(path)

    if recipes_path.exist? && recipes_path.to_s.match(/\.(tgz|tar\.gz)/)
      environment.upload_recipes(recipes_path)
    elsif recipes_path.exist?
      environment.upload_recipes(archive_directory(path))
    else
      raise Ey::Core::Cli::RecipesNotFound, "Recipes file not found: #{recipes_path}"
    end
  end

  def ungzip(tarfile)
    z = Zlib::GzipReader.new(tarfile)
    unzipped = StringIO.new(z.read)
    z.close
    unzipped
  end


  def untar(io, destination)
    Gem::Package::TarReader.new io do |tar|
      tar.each do |tarfile|
        destination_file = File.join destination, tarfile.full_name

        if tarfile.directory?
          FileUtils.mkdir_p destination_file
        else
          destination_directory = File.dirname(destination_file)
          FileUtils.mkdir_p destination_directory unless File.directory?(destination_directory)
          File.open destination_file, "wb" do |f|
            f.print tarfile.read
          end
        end
      end
    end
  end
end
