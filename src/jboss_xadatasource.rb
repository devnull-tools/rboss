require_relative "jboss_datasource"
require_relative "file_processor"
require_relative "jboss_path"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

module JBoss

  # A class to configure a JBoss XADatasource.
  #
  # The configuration will change a <xa-datasource-property> value.
  #
  # Configuration attributes are the same as for a JBoss::Datasource
  #
  # author: Marcelo Guimaraes <ataxexe@gmail.com>
  class XADatasource < JBoss::Datasource
    include FileProcessorBuilder, CommandInvoker

    def initialize jboss, logger, config
      super jboss, logger, config
      @type << "-xa"
    end

    def configure_datasource xml
      if @encrypt
        xml.delete_element "//xa-datasource-property[@name='User']"
        xml.delete_element "//xa-datasource-property[@name='Password']"
        @service = "XATxCM"
      end
      @attributes.each do |key, value|
        element = find(xml, key) {|k| "//xa-datasource-property[@name='#{k}']"}

        if element
          element.text = value
        else
          insert_attribute xml, key, value
        end
      end
    end

  end

end
