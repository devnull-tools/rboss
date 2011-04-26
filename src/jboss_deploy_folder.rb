require_relative "file_processor"
require_relative "jboss_path"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

module JBoss

  # A class to add deploy folders to a JBoss Profile.
  #
  #
  #
  #
  # author: Marcelo Guimaraes <ataxexe@gmail.com>
  class DeployFolder
    include CommandInvoker, FileProcessorBuilder

    def initialize jboss, logger, folder
      @jboss = jboss
      @logger = logger
      @folder = folder.to_s
      @absolute_path = @folder.start_with? '/'
      if @absolute_path
        @path = @folder
      else
        @path = @jboss.profile.deploy @folder
        @folder = "${jboss.server.home.url}#{@folder}" unless @folder.start_with? '/'
      end
    end

    def process
      @logger.info "Creating deploy folder: #{@path}"
      invoke "mkdir -p #{@path}"
      if @absolute_path
        configure_vfs
        configure_profile
      end
    end

    private

    def configure_profile
      @logger.info "Updating profile.xml"
      processor = create_file_processor
      processor.with @jboss.profile.conf.bootstrap('profile.xml'), :xml do |action|
        action.to_process do |xml, jboss|
          element = XPath.first xml, "//property[@name='applicationURIs']"
          element = XPath.first element, "//list[@elementClass='java.net.URI']"
          deploy = Element::new "value"
          deploy.text = @folder
          element << deploy
          xml
        end
        action.return
      end
      processor.process
    end

    def configure_vfs
      @logger.info "Updating vfs.xml"
      processor = create_file_processor
      processor.with @jboss.profile.conf.bootstrap('vfs.xml'), :xml do |action|
        action.to_process do |xml, jboss|
          map = XPath.first xml, "//map[@keyClass='java.net.URL']"
          entry = Document::new <<XML
<entry>
  <key>#{@folder}</key>
  <value><inject bean="VfsNamesExceptionHandler"/></value>
</entry>
XML
          map << entry
          xml
        end
      end
      processor.process
    end

  end

end
