require_relative 'cli/jboss_cli'
require_relative 'cli/mappings'
require_relative 'cli/resource'
require_relative 'cli/formatters'
require_relative 'cli/health_checkers'

file = File.expand_path("~/.rboss/rboss-cli.yaml")

if File.exist? file
  JBoss::Cli::Mappings.load_mappings file
end

if RUBY_PLATFORM['linux']
  class JBoss::Cli::Invoker

    def jboss_cli
      "#@jboss_home/bin/jboss-cli.sh"
    end

  end
elsif RUBY_PLATFORM['mingw'] #Windows
  class JBoss::Cli::Invoker

    def jboss_cli
      "#@jboss_home/bin/jboss-cli.bat"
    end

  end
else
  puts "Platform #{RUBY_PLATFORM} not supported"
end

