require_relative "file_processor"
require_relative "jboss"
require_relative "jboss_datasource"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

# A class to replace the shipped Hypersonic datasource for a JBoss instance.
#
# Configuration:
#
# The configuration can be a JBossDatasource or a Hash to configure a JBossDatasource.
#
# author: Marcelo Guimaraes <ataxexe@gmail.com>
class JBossHypersonicReplacer
  include CommandInvoker

  def initialize jboss, logger, config
    @jboss = jboss
    @logger = logger
    @datasource = config if config.is_a? JBossDatasource
    @datasource ||= JBossDatasource::new(@jboss, @logger, config) if config.is_a? Hash
  end

  def process
    @logger.info "Removing Hypersonic..."
    invoke "rm -f #{@jboss.instance.deploy 'hsqldb-ds.xml'}"
    invoke "rm -f #{@jboss.instance.deploy.messaging 'hsqldb-persistence-service.xml'}"

    @datasource
    @datasource.jndi_name = "DefaultDS"

    @datasource.process

    @logger.info "Copying persistence service template for #{@datasource.type}..."
    invoke "cp #{@jboss.docs.examples.jms}/#{@datasource.type}-persistence-service.xml #{@jboss.instance.deploy.messaging}"
  end

end
