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

module JBoss
  module Twiddle
    class Invoker

      attr_reader :jboss_ip, :jboss_port, :jboss_home, :jmx_user, :jmx_password
      attr_accessor :command

      def initialize params = {}
        params = {
          :jboss_home => ENV["JBOSS_HOME"],
          :jboss_ip => '127.0.0.1',
          :jboss_port => 1099,
          :jmx_user => "admin",
          :jmx_password => "admin"
        }.merge! params
        @jboss_home = params[:jboss_home]

        @jboss_ip = params[:jboss_ip]
        @jboss_port = params[:jboss_port]

        @jmx_user = params[:jmx_user]
        @jmx_password = params[:jmx_password]

        @command = "#{@jboss_home}/bin/twiddle.sh -s #{@jboss_ip}:#{@jboss_port} -u '#{@jmx_user}' -p '#{@jmx_password}'"
      end

      def home
        @jboss_home
      end

      def invoke command, *arguments
        execute(shell command, arguments)
      end

      def shell operation, *arguments
        "#{command} #{operation} #{arguments.join " "}"
      end

      def get_system_property property
        invoke :invoke, 'jboss:name=SystemProperties,type=Service', 'get', property
      end

      def execute shell
        `#{shell}`.chomp
      end

      alias_method :[], :get_system_property

    end

    class ResourceDiscoverer

      def initialize invoker = Invoker::new
        @twiddle = invoker
      end

      def webapps
        result = @twiddle.invoke :query, "jboss.web:type=Manager,*"
        webapps = result.split(/\s+/)
        webapps.collect do |path|
          path.gsub! "jboss.web:type=Manager,path=/", ""
          path.gsub! /,host=.+/, ''
          path
        end
      end

      def datasources
        result = @twiddle.invoke :query, "jboss.jca:service=ManagedConnectionPool,*"
        datasources = result.split(/\s+/)
        datasources.collect { |path| path.gsub "jboss.jca:service=ManagedConnectionPool,name=", "" }
      end

      def connectors
        result = @twiddle.invoke :query, "jboss.web:type=ThreadPool,*"
        connectors = result.split(/\s+/)
        connectors.collect { |path| path.gsub "jboss.web:type=ThreadPool,name=", "" }
      end

    end

  end
end
