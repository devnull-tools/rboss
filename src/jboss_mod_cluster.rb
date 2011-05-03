#                         The MIT License
#
# Copyright (c) 2011 Marcelo Guimarães <ataxexe@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative "jboss_component"
require_relative "jboss_path"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

module JBoss
  # A class to install and configure a mod_cluster service in a JBoss profile
  #
  # Configuration:
  #
  # :path => where the mod_cluster.sar is located
  # :folder => where the mod_cluster.sar should be installed (default: $JBOSS_HOME/server/$CONFIG/deploy)
  #
  # The additional configurations are the entries in the bean ModClusterConfig (mod_cluster-jboss-beans.xml)
  # and can be in a String form (using the entry name) or in a Symbol form (using ruby nomenclature - :sticky_session)
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class ModCluster
    include CommandInvoker, Component

    def initialize jboss, logger, config
      @jboss = jboss
      @logger = logger
      config = {
        :folder => @jboss.profile.deploy
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
            element = XPath.first config, "property[@name='#{property.to_s.camelize.uncapitalize}']"
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
end
