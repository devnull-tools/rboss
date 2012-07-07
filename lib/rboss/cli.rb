require_relative 'cli/jboss_cli'
require_relative 'cli/mappings'
require_relative 'cli/component'

file = ENV["RBOSS_CLI"] || File.expand_path("~/.rboss/rboss-cli.rb")

eval File.read(file), binding, file if File.exist? file
