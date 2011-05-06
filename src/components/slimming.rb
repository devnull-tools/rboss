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

require_relative 'component'

module JBoss
  # A class for slimming a JBoss profile
  #
  # Configuration:
  #
  # Pass an array with the services to remove, the current supported are:
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
  # Each service is binded to a remove_$SERVICE_ID method so you can easily add
  # more services by modifying this class
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class Slimming
    include Component

    def initialize jboss, logger, services_to_remove
      @jboss = jboss
      @logger = logger
      @services_to_remove = services_to_remove
    end

    def process
      @services_to_remove.each do |service|
        message = "remove_#{service}".to_sym
        @logger.info "Removing #{service}"
        self.send message
      end
    end

    def remove_hot_deploy
      reject("#{@jboss.profile}/deploy/hdscanner-jboss-beans.xml")
    end

    def remove_juddi
      reject("#{@jboss.profile}/deploy/juddi-service.sar")
    end

    def remove_key_generator
      reject("#{@jboss.profile}/deploy/uuid-key-generator.sar")
    end

    def remove_mail
      reject("#{@jboss.profile}/deploy/mail-ra.rar")
      reject("#{@jboss.profile}/deploy/mail-service.xml")
    end

    def remove_scheduling
      reject("#{@jboss.profile}/deploy/scheduler-manager-service.xml")
      reject("#{@jboss.profile}/deploy/scheduler-service.xml")
    end

    def remove_bsh_deployer
      reject("#{@jboss.profile}/deployers/bsh.deployer")
    end

    def remove_jboss_ws
      reject("#{@jboss.profile}/conf/jax-ws-catalog.xml")
      reject("#{@jboss.profile}/conf/props/jbossws-users.properties")
      reject("#{@jboss.profile}/conf/props/jbossws-roles.properties")
      reject("#{@jboss.profile}/deploy/jbossws.sar")
      reject("#{@jboss.profile}/deployers/jbossws.deployer")
    end

    def remove_jmx_console
      reject("#{@jboss.profile}/deploy/jmx-console.war")
    end

    def remove_admin_console
      reject("#{@jboss.profile}/deploy/admin-console.war")
    end

    def remove_web_console
      reject("#{@jboss.profile}/deploy/management")
    end

    def remove_jmx_remoting
      reject("#{@jboss.profile}/deploy/jmx-remoting.sar")
    end

    private

    def reject file
      invoke "mv #{file} #{file}.rej"
    end

  end

end
