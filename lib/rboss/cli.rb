require_relative 'cli/jboss_cli'

if RUBY_PLATFORM['linux']
  class RBoss::Cli::Invoker

    def jboss_cli
      "#@jboss_home/bin/jboss-cli.sh"
    end

  end
elsif RUBY_PLATFORM['mingw'] #Windows
  class RBoss::Cli::Invoker

    def jboss_cli
      "#@jboss_home/bin/jboss-cli.bat"
    end

  end
else
  puts "Platform #{RUBY_PLATFORM} not supported"
end

