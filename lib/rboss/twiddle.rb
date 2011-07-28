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

      attr_reader :jboss_host, :jboss_port, :jboss_home, :jmx_user, :jmx_password
      attr_accessor :command

      def initialize params = {}
        params = {
          :jboss_home => ENV["JBOSS_HOME"],
          :jboss_server => nil,
          :jboss_host => '127.0.0.1',
          :jboss_port => 1099,
          :jmx_user => "admin",
          :jmx_password => "admin"
        }.merge! params
        @jboss_home = params[:jboss_home]

        @jboss_host = params[:jboss_host]
        @jboss_port = params[:jboss_port]
        @jboss_server = params[:jboss_server]
        @jboss_server ||= [@jboss_host, @jboss_port].join ':'

        @jmx_user = params[:jmx_user]
        @jmx_password = params[:jmx_password]

        @command = "#{@jboss_home}/bin/twiddle.sh -s #{@jboss_server} -u '#{@jmx_user}' -p '#{@jmx_password}'"
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

    module Scanner

      def current_scan
        @current_scan
      end

      def webapps
        @current_scan = :webapp
        _query_ "jboss.web:type=Manager,*" do |path|
          path.gsub! "jboss.web:type=Manager,path=/", ""
          path.gsub! /,host=.+/, ''
          path
        end
      end

      def datasources
        @current_scan = :datasource
        _query_ "jboss.jca:service=ManagedConnectionPool,*" do |path|
          path.gsub "jboss.jca:service=ManagedConnectionPool,name=", ""
        end
      end

      def connectors
        @current_scan = :connector
        _query_ "jboss.web:type=ThreadPool,*" do |path|
          path.gsub "jboss.web:type=ThreadPool,name=", ""
        end
      end

      def queues
        @current_scan = :queue
        _query_ "jboss.messaging.destination:service=Queue,*" do |path|
          path.gsub "jboss.messaging.destination:service=Queue,name=", ""
        end
      end

      def deployments
        @current_scan = :deployment
        _query_ "jboss.web.deployment:*" do |path|
          path.gsub "jboss.web.deployment:", ""
        end
      end

      def can_scan? resource
        self.respond_to? resource.to_sym
      end

      private

      def _query_ query, &block
        result = @twiddle.invoke(:query, query).split /\s+/
        block ? result.collect(&block) : result
      end

    end

  end
end
