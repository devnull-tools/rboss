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

require_relative 'result_parser'
require_relative 'resource'
require_relative 'mappings'

require 'logger'

require 'yummi'
require 'yaml'

module RBoss

  module Cli

    class Invoker
      include RBoss::Cli::Mappings, RBoss::Platform, RBoss::Cli::ResultParser

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

        @skip_optional = params[:skip_optional]
      end

      def command
        command = "#{jboss_cli} --connect"
        command << " --controller=#@server" if @server
        command << " --user='#@user'" if @user
        command << " --password='#@password'" if @password
        command
      end

      def invoke(operation, resources, parameters)
        buff = ""
        resources.each do |key, resource_names|
          if resource_mappings.has_key? key
            mapping = resource_mappings[key]
            resource = RBoss::Cli::Resource::new(self, mapping)
            result = resource.invoke(operation, resource_names, parameters)
            buff << result.to_s if result
          end
        end
        buff
      end

      def gets_and_invoke(path, operation, parameters)
        result = result("#{path}:read-operation-description(name=#{operation})")
        props = result["request-properties"]
        props ||= {}
        builder = CommandBuilder::new operation
        help_printed = false
        info = Yummi::colorize("Please input the requested parameters", :yellow)
        props.each do |name, detail|
          next if (@skip_optional and not detail['required'] or detail['default'])
          input = parameters[name]
          unless input
            puts info unless help_printed
            help_printed = true
            input_message = Yummi::colorize(name, :intense_blue)
            required = detail['required']
            default_value = detail['default']
            input_message << ' | ' << RBoss::Colorizers.type(detail['type']).colorize(detail['type'])
            input_message << ' | ' << Yummi::colorize("Required", :red) if required
            input_message << ' | ' << Yummi::colorize("Optional", :cyan) unless required
            input_message << ' | ' << Yummi::colorize("Default: #{default_value}", :blue) if default_value
            input_message << "\n" << Yummi::colorize(detail['description'], :intense_gray)
            puts input_message
            input = get_input
            while required and input.empty?
              puts Yummi::colorize("Required parameter!", :red)
              input = get_input
            end
          end
          next if input.empty?
          builder << {:name => name, :value => detail['type'].convert(input)}
        end
        result = result("#{path}:#{builder}")
        puts Yummi::colorize("Result:", :yellow)
        #TODO print a table using the returned parameters
        puts YAML::dump(result)
      end

      def execute(*commands)
        exec = "#{command} --command#{commands.size > 1 ? 's' : ''}=\"#{commands.join ','}\""
        @logger.debug exec
        `#{exec}`.chomp
      end

      def result(*commands)
        eval_result(execute commands)
      end

      private

      def get_input
        gets.chomp.strip
      end

    end

    class CommandBuilder

      def initialize (operation)
        @operation = operation
        @params = {}
      end

      def << (param)
        @params[param[:name]] = param[:value]
      end

      def to_s
        params = (@params.collect() { |k, v| "#{k}=#{v}" }).join ','
        "#@operation(#{params})"
      end

    end

  end

end
