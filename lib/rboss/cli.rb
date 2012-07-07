require_relative 'cli/jboss_cli'
require_relative 'cli/mappings'
require_relative 'cli/component'
require_relative 'cli/formatters'
require_relative 'cli/health_checkers'

file = File.expand_path("~/.rboss/rboss-cli.yaml")

if File.exist? file
  JBoss::Cli::Mappings.load_mappings file
end
