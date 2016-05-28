require 'stringio'
require 'rubygems/package'
require 'zlib'

module Ey
  module Core
    module Cli
      module Helpers
        module Archive
          def gzip(tarfile)
            gz = StringIO.new("")
            zipper = Zlib::GzipWriter.new(gz)
            zipper.write tarfile.string
            zipper.close # this is necessary!

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

          def ungzip(tarfile)
            zipped = Zlib::GzipReader.new(tarfile)
            unzipped = StringIO.new(zipped.read)
            zipped.close
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
                  File.open destination_file, "wb" do |file|
                    file.print tarfile.read
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
