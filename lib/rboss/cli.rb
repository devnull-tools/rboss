require_relative 'cli/jboss_cli'

file = ENV["RBOSS_CLI"] || File.expand_path("~/.rboss/rboss-cli.rb")

eval File.read(file), binding, file if File.exist? file
