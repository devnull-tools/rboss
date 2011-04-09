require_relative "file_processor"
require_relative "jboss"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

# A class to install and configure a mod_cluster service in a JBoss instance
#
# Configuration:
#
# :path => where the mod_cluster.sar is located
# :folder => where the mod_cluster.sar should be installed (default: $JBOSS_HOME/server/$CONFIG/deploy)
#
#
class JBossModCluster
  include CommandInvoker, FileProcessorBuilder

  def initialize jboss, logger, config
    @jboss = jboss
    @logger = logger
    config = {
      :folder => @jboss.instance.deploy
    }.merge! config
    @path = config.delete :path
    @folder = config.delete :folder
    @config = config
  end

  def process
    @logger.info "Installing mod_cluster.sar"
    invoke "cp -r #{@path} #{@folder}"

    return if @config.empty?

    @logger.info "Configuring mod_cluster.sar"
    processor = create_file_processor
    processor.with "#{@folder}/mod_cluster.sar/META-INF/mod_cluster-jboss-beans.xml", :xml do |action|
      action.to_process do |xml, jboss|
        config = XPath.first(xml, "//bean[@name='ModClusterConfig']")
        @config.each do |property, value|
          element = XPath.first config, "property[@name='#{property.to_s.to_jboss_property.uncapitalize}']"
          if element
            @logger.debug "Configuring #{element.attribute('name').value} to \"#{value}\""
            element.text = value
          end
        end
        xml
      end
    end
    processor.process
  end

end
