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

require_relative 'formatters'
require_relative 'colorizers'
require_relative 'health_checkers'

module JBoss
  module Cli
    class Resource

      def initialize(invoker, config)
        @config = config
        @invoker = invoker
        @context = {
          :name => ''
        }
        @context[:path] = parse(@config[:path])
        @tables = []
        @count = 0
      end

      def print(resources)
        if :all == resources
          resources = scan
        end
        resources = [resources] unless resources.is_a? Array
        params = @config[:print]
        params.each do |p|
          @tables << build_table(p)
        end
        resources.each do |resource|
          @context[:name] = resource
          @context[:path] = parse(@config[:path])

          params.each do |p|
            add_row(p)
          end
        end
        @tables.each do |table|
          table.print
          puts
        end
      end

      def add_row(params)
        data = get_data(params)
        return unless data
        data = [@context[:name]] + data if scannable?
        @tables[@count % @tables.size].data << data
        @count += 1
      end

      def parse(value)
        result = value.scan /\$\{\w+\}/
        result.each do |matched|
          key = matched[2...-1].downcase.to_sym
          value = value.gsub(matched, @context[key])
        end
        value
      end

      def scan
        result = @invoker.execute(parse @config[:scan])
        result.split "\n"
      end

      def build_table(config)
        table = Yummi::Table::new
        table.title = config[:description]
        header = config[:header]
        header = %w(Name) + header if scannable?
        if config[:aliases]
          aliases = config[:aliases]
          aliases = [:name] + aliases if scannable?
          table.aliases = aliases
        end
        table.header = header
        table.layout = config[:layout].to_sym if config[:layout]

        parse_component config[:format], JBoss::Cli::Formatters do |column, params|
          table.format column, params
        end
        parse_component config[:color], JBoss::Cli::Colorizers do |column, params|
          table.colorize column, params
        end
        parse_component config[:health], JBoss::Cli::HealthCheckers do |column, params|
          table.using_row do
            table.colorize column, params
          end
        end

        table.colorize :name, :with => :white if scannable?

        table
      end

      def scannable?
        @config[:scan]
      end

      def parse_component(config, repository)
        if config
          config.each do |component_config|
            component = repository.send(component_config[:component]) unless component_config[:params]
            component ||= repository.send(component_config[:component], component_config[:params])
            yield(component_config[:column].to_sym, :using => component)
          end
        end
      end

      def get_data(config)
        result = @invoker.execute(parse config[:command])
        result = eval_result(result)
        data = []
        config[:properties].each do |prop|
          data << result["result"][prop]
        end
        data
      end

      def eval_result(result)
        undefined = nil #prevents error because undefined means nil in result object
        eval(result)
      end

    end
  end
end
