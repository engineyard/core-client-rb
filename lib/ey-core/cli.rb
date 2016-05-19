require 'optparse'
require 'ostruct'
require 'ey-core'
require 'awesome_print'
require 'pry'
require 'belafonte'
require 'table_print'
require 'rubygems/package'
require 'escape'

Cistern.formatter = Cistern::Formatter::AwesomePrint


class Ey::Core::Cli < Belafonte::App
  title "Engineyard CLI"
  summary "Successor to the engineyard gem"

  require_relative "cli/subcommand"
  Dir[File.dirname(__FILE__) + '/cli/*.rb'].each {|file| load file }

  Ey::Core::Cli::Subcommand.descendants.each do |d|
    mount d
  end
end
