require 'optparse'
require 'ostruct'
require 'ey-core'
require 'ey-core/cli'
require 'awesome_print'
require 'pry'
require 'belafonte'
require 'table_print'
require 'rubygems/package'
require 'escape'
require 'highline/import'

Cistern.formatter = Cistern::Formatter::AwesomePrint


class Ey::Core::Cli::Main < Belafonte::App
  title "Engineyard CLI"
  summary "Successor to the engineyard gem"

  require_relative "subcommand"
  Dir[File.dirname(__FILE__) + '/*.rb'].
    reject {|file| file =~ /.*\/main\.rb$/}.
    each {|file| load file }

  Ey::Core::Cli::Subcommand.descendants.each do |d|
    mount d
  end
end
