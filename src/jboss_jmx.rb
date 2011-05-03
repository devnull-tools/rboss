require_relative "jboss_component"

module JBoss
  # This class configures the JXM user for a JBoss profile.
  #
  # Configuration:
  #
  # :user => the jxm user (default: 'admin')
  # :password => the jmx user password (default: 'admin')
  # :roles => the roles mapped for the user (default: 'JBossAdmin,HttpInvoker')
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class JMX
    include Component

    def initialize jboss, logger, config
      config = {
        :user => "admin",
        :password => "admin",
        :roles => "JBossAdmin,HttpInvoker"
      }.merge! config
      @jboss = jboss
      @logger = logger
      @password = config[:password]
      @user = config[:user]
      @roles = config[:roles]
    end

    def process
      configure_users
      configure_roles
    end

    def configure_users
      processor = create_file_processor
      processor.with @jboss.profile.conf.props "jmx-console-users.properties" do |action|
        action.to_process do |content, jboss|
          [@user, @password].join '='
        end
      end
      processor.process
    end

    def configure_roles
      processor = create_file_processor
      processor.with @jboss.profile.conf.props "jmx-console-roles.properties" do |action|
        action.to_process do |content, jboss|
          [@user, @roles].join '='
        end
      end
      processor.process
    end

  end

end
