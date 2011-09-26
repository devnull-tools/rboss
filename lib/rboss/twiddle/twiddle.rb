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

require 'logger'

module JBoss
  module Twiddle
    class Invoker

      attr_reader :server, :host, :port, :home, :user, :password
      attr_accessor :command

      def initialize params = {}
        params = {
          :jboss_home => ENV["JBOSS_HOME"],
          :server => nil,
          :host => '127.0.0.1',
          :port => 1099,
          :user => "admin",
          :password => "admin"
        }.merge! params
        @jboss_home = params[:jboss_home]

        @server = params[:server]
        @host = params[:host]
        @port = params[:port]
        @server ||= [@host, @port].join ':'

        @user = params[:user]
        @password = params[:password]

        @command = "#{@jboss_home}/bin/twiddle.sh -s #{@server} -u '#{@user}' -p '#{@password}'"

        @logger = params[:logger]
        unless @logger
          @logger = Logger::new STDOUT
          @logger.level = params[:log_level] || Logger::INFO
          formatter = Logger::Formatter.new

          def formatter.call(severity, time, program_name, message)
            "#{severity} : #{message}\n"
          end

          @logger.formatter = formatter
        end
      end

      def home
        @jboss_home
      end

      def shell operation, *arguments
        "#{command} #{operation} #{arguments.join " "}"
      end

      def execute command, *arguments
        exec = shell command, arguments
        @logger.debug exec
        result = `#{exec}`.chomp
        return nil if result["ERROR [Twiddle] Command failure"]
        result
      end

    end

  end
end
