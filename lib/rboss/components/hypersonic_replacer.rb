#                         The MIT License
#
# Copyright (c) 2011-2012 Marcelo Guimarães <ataxexe@gmail.com>
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

require_relative "datasource"
require_relative "component"

module JBoss
  # A class to replace the shipped Hypersonic datasource for a JBoss profile.
  #
  # Configuration:
  #
  # The configuration can be a JBossDatasource or a Hash to configure a JBossDatasource.
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class HypersonicReplacer
    include Component, FileUtils

    def configure config
      @datasource = config if config.is_a? Datasource
      @datasource ||= Datasource::new(@jboss, @logger, config)
      @datasource.jndi_name = "DefaultDS"
    end

    def process
      @logger.info "Removing Hypersonic..."
      rm_f "#{@jboss.profile}/deploy/hsqldb-ds.xml"
      rm_f "#{@jboss.profile}/deploy/messaging/hsqldb-persistence-service.xml"

      @datasource.process

      @logger.info "Copying persistence service template for #{@datasource.type}..."
      # For postgres, the jms example filename differs from jca
      @datasource.type = :postgresql if @datasource.type.to_s == "postgres"
      cp "#{@jboss.home}/docs/examples/jms/#{@datasource.type}-persistence-service.xml", "#{@jboss.profile}/deploy/messaging"
    end

  end

end
