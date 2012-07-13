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

require_relative 'component'

module RBoss
  # A class for slimming a JBoss profile
  #
  # Configuration:
  #
  # Pass an array with the services to remove, the current supported are:
  #
  #   Admin Console       => :admin_console
  #   Web Console         => :web_console
  #   Mail Service        => :mail
  #   BeanShell           => :bean_shell
  #   Hot Deploy          => :hot_deploy
  #   UDDI                => :uddi
  #   UUID Key Generator  => :key_generator
  #   Scheduling          => :scheduling
  #   JMX Console         => :jmx_console
  #   JBoss WS            => :jboss_ws
  #   JMX Remoting        => :jmx_remoting
  #   ROOT Page           => :root_page
  #   Management          => :management
  #   IIOP                => :iiop
  #   JBoss Web           => :jboss_web
  #   SNMP                => :snmp
  #   Profile Service     => :profile
  #   EJB3                => :ejb3
  #   EJB2                => :ejb2
  #   JMX Invoker         => :jmx_invoker
  #   HA HTTP Invoker     => :ha_http_invoker
  #   Legacy Invoker      => :legacy_invoker
  #   Transaction         => :transaction
  #   Remoting            => :remoting
  #   Properties Service  => :properties
  #   Database/Datasource => :database
  #   JSR-88              => :jsr88
  #   XNIO                => :xnio
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class Slimming
    include Component, FileUtils

    def configure services_to_remove
      @services_to_remove = services_to_remove.is_a?(Array) ? services_to_remove : [services_to_remove]
      @mapping = {}
      load_yaml('slimming').each do |key, values|
        @mapping[key.to_sym] = values
      end
    end

    def process
      @services_to_remove.each do |service|
        log service
        slim service
      end
    end

    def slim service
      sym = service.to_s.gsub(/-/, '_').to_sym
      entry = @mapping[sym]
      method = "remove_#{service}".to_sym
      if respond_to? method
        self.send method
      elsif entry
        entry.each do |file|
          handle file if file.is_a? String
          slim file if file.is_a? Symbol
        end
      else
        raise "Unrecognized service: #{service}"
      end
    end

    def log service
      @logger.info "Disabling #{service}"
    end

    def handle file
      file = "#{@jboss.profile}/" + file unless file.start_with? '/'
      mv(file, file + ".rej") if File.exist? file
    end

  end

end
