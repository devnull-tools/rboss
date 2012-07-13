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

require_relative 'resource'
require_relative 'mappings'

require 'logger'

module RBoss

  module Cli

    class Invoker
      include RBoss::Cli::Mappings, RBoss::Platform

      attr_reader :server, :host, :port, :user, :password

      def initialize(params = {})
        params = {
          :jboss_home => ENV["JBOSS_HOME"],
        }.merge! params

        @jboss_home = params[:jboss_home]

        @server = params[:server]
        @host = params[:host]
        @port = params[:port]
        @server ||= [@host, @port].join ':' if @host and @port

        @user = params[:user]
        @password = params[:password]

        @logger = params[:logger]
        unless @logger
          @logger = Logger::new STDOUT
          @logger.level = params[:log_level] || Logger::INFO
          formatter = Yummi::Formatter::LogFormatter.new do |severity, message|
            "#{severity} : #{message}"
          end
          @logger.formatter = formatter
        end
      end

      def command
        command = "#{jboss_cli} --connect"
        command << " --controller=#@server" if @server
        command << " --user='#@user'" if @user
        command << " --password='#@password'" if @password
        command
      end

      def content(components)
        buff = ""
        components.each do |key, resources|
          if resource_mappings.has_key? key
            mapping = resource_mappings[key]
            component = RBoss::Cli::Resource::new(self, mapping)
            buff << component.content(resources)
            buff << $/
          end
        end
        buff
      end

      def execute(*commands)
        exec = "#{command} --commands=\"#{commands.join ','}\""
        @logger.debug exec
        `#{exec}`.chomp
      end

    end

  end

end
