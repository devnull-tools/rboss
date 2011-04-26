require_relative "file_processor"
require_relative "jboss_datasource"
require_relative "command_invoker"

module JBoss
  # A class to replace the shipped Hypersonic datasource for a JBoss profile.
  #
  # Configuration:
  #
  # The configuration can be a JBossDatasource or a Hash to configure a JBossDatasource.
  #
  # author: Marcelo Guimaraes <ataxexe@gmail.com>
  class HypersonicReplacer
    include CommandInvoker

    def initialize jboss, logger, config
      @jboss = jboss
      @logger = logger
      @datasource = config unless config.is_a? Hash
      @datasource ||= JBoss::Datasource::new(@jboss, @logger, config)
    end

    def process
      @logger.info "Removing Hypersonic..."
      invoke "rm -f #{@jboss.profile.deploy 'hsqldb-ds.xml'}"
      invoke "rm -f #{@jboss.profile.deploy.messaging 'hsqldb-persistence-service.xml'}"

      @datasource.jndi_name = "DefaultDS"

      @datasource.process

      @logger.info "Copying persistence service template for #{@datasource.type}..."
      invoke "cp #{@jboss.docs.examples.jms}/#{@datasource.type}-persistence-service.xml #{@jboss.profile.deploy.messaging}"
    end

  end

end
