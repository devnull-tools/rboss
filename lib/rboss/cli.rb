require_relative 'cli/jboss_cli'
require_relative 'cli/mappings'
require_relative 'cli/component'

file = File.expand_path("~/.rboss/rboss-cli.yaml")

if File.exist? file
  JBoss::Cli::Mappings.load_mappings file
end
