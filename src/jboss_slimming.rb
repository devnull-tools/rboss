require_relative "file_processor"
require_relative "jboss"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

# A class for slimming a JBoss profile
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
    reject(@jboss.profile.deploy "hdscanner-jboss-beans.xml")
  end

  def remove_juddi
    reject(@jboss.profile.deploy 'juddi-service.sar')
  end

  def remove_key_generator
    reject(@jboss.profile.deploy 'uuid-key-generator.sar')
  end

  def remove_mail
    reject(@jboss.profile.deploy 'mail-ra.rar')
  end

  def remove_scheduling
    %w{scheduler-manager-service.xml scheduler-service.xml}.each do |file|
      reject(@jboss.profile.deploy file)
    end
  end

  def remove_bsh_deployer
    reject(@jboss.profile.deployers 'bsh.deployer')
  end

  def remove_jboss_ws
    reject(@jboss.profile.conf 'jax-ws-catalog.xml')
    reject(@jboss.profile.conf.props 'jbossws-users.properties')
    reject(@jboss.profile.conf.props 'jbossws-roles.properties')
    reject(@jboss.profile.deploy 'jbossws.sar')
    reject(@jboss.profile.deployers 'jbossws.deployer')
  end

  def remove_jmx_console
    reject(@jboss.profile.deploy 'jmx-console.war')
  end

  def remove_admin_console
    reject(@jboss.profile.deploy 'admin-console.war')
  end

  def remove_web_console
    reject(@jboss.profile.deploy 'management')
  end

  def remove_jmx_remoting
    reject(@jboss.profile.deploy 'jmx-remoting.sar')
  end

  private

  def reject file
    invoke "mv #{file} #{file}.rej"
  end

end
