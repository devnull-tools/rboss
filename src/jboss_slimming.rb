require_relative "file_processor"
require_relative "jboss"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

# A class for slimming a JBoss instance
#
# Configuration:
#
# :remove => array with the services to remove, the current supported are:
#
#   Admin Console       => :admin_console
#   Web Console         => :web_console
#   Mail Service        => :mail
#   Bsh Deployer        => :bsh_deployer
#   Hot Deploy          => :hot_deploy
#   JUDDI               => :juddi
#   UUID Key Generator  => :key_generator
#   Scheduling          => :scheduling
#   JMX Console         => :jmx_console
#   JBoss WS            => :jboss_ws
#   JMX Remoting        => :jmx_remoting
#
# author: Marcelo Guimaraes <ataxexe@gmail.com>
class JBossSlimming
  include CommandInvoker, FileProcessorBuilder

  def initialize jboss, logger, config
    @jboss = jboss
    @logger = logger
    @services_to_remove = config[:remove]
  end

  def process
    @services_to_remove.each do |service|
      message = "remove_#{service}".to_sym
      @logger.info "Removing #{service}"
      self.send message
    end
  end

  def remove_hot_deploy
    invoke "rm -f #{@jboss.instance.deploy 'hdscanner-jboss-beans.xml'}"
  end

  def remove_juddi
    invoke "rm -rf #{@jboss.instance.deploy 'juddi-service.sar'}"
  end

  def remove_key_generator
    invoke "rm -rf #{@jboss.instance.deploy 'uuid-key-generator.sar'}"
  end

  def remove_mail
    invoke "rm -rf #{@jboss.instance.deploy 'mail-ra.rar'}"
  end

  def remove_scheduling
    %w{scheduler-manager-service.xml scheduler-service.xml}.each do |file|
      invoke "rm -f #{@jboss.instance.deploy file}"
    end
  end

  def remove_bsh_deployer
    invoke "rm -rf #{@jboss.instance.deployers 'bsh.deployer'}"
  end

  def remove_jboss_ws
    invoke "rm -f #{@jboss.instance.conf 'jax-ws-catalog.xml'}"
    invoke "rm -f #{@jboss.instance.conf.props 'jbossws-users.properties'}"
    invoke "rm -f #{@jboss.instance.conf.props 'jbossws-roles.properties'}"
    invoke "rm -rf #{@jboss.instance.deploy 'jbossws.sar'}"
    invoke "rm -rf #{@jboss.instance.deployers 'jbossws.deployer'}"
  end

  def remove_jmx_console
    invoke "rm -rf #{@jboss.instance.deploy 'jmx-console.war'}"
  end

  def remove_admin_console
    invoke "rm -rf #{@jboss.instance.deploy 'admin-console.war'}"
  end

  def remove_web_console
    invoke "rm -rf #{@jboss.instance.deploy 'management'}"
  end

  def remove_jmx_remoting
    invoke "rm -rf #{@jboss.instance.deploy 'jmx-remoting.sar'}"
  end

end
