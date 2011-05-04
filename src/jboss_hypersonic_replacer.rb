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
  # author: Marcelo Guimarães <ataxexe@gmail.com>
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
      invoke "rm -f #{@jboss.profile}/deploy/hsqldb-ds.xml"
      invoke "rm -f #{@jboss.profile}/deploy/messaging/hsqldb-persistence-service.xml"

      @datasource.jndi_name = "DefaultDS"

      @datasource.process

      @logger.info "Copying persistence service template for #{@datasource.type}..."
      invoke "cp #{@jboss.home}/docs/examples/jms/#{@datasource.type}-persistence-service.xml #{@jboss.profile}/deploy/messaging"
    end

  end

end
