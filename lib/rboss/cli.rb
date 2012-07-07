require_relative 'cli/jboss_cli'

file = File.expand_path("~/.rboss/rboss-cli/resources")

if File.exist? file
  JBoss::Cli::Mappings.load_resources file
else

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

