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


module RBoss
  module Cli
    class Resource

      def initialize(invoker, config)
        @config = config
        @invoker = invoker
        @context = {
          :name => '',
          :read_resource => 'read-resource(include-runtime=true)'
        }
        @context[:path] = parse(@config[:path])
        @tables = []
        @count = 0
      end

      def invoke(operation, argument)
        if respond_to? operation
          send operation, argument
        else
          interact_to_invoke operation, argument
          Yummi.colorize('Operation Executed!', :green)
        end
      end

      def read_resource(resources)
        resources ||= scan
        params = @config[:print]
        params.each do |p|
          table_builder = RBoss::TableBuilder::new p
          table_builder.add_name_column if scannable?
          @tables << table_builder.build_table
        end
        with resources do
          params.each do |p|
            @context[:path] = parse(@config[:path])
            @context[:path] = parse(p[:path]) if p[:path]
            add_row(p)
          end
        end
        result = ""
        @tables.each do |table|
          result << table.to_s
          result << $/
        end
        result
      end

      private

      def interact_to_invoke(operation, resource_name)
        resource_name ||= operation
        with resource_name do
          @invoker.gets_and_invoke(@context[:path], operation)
        end
      end

      def with(resources)
        [*resources].each do |resource|
          @context[:name] = resource
          @context[:path] = parse(@config[:path])
          yield
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
        return nil unless value
        result = value.scan /\$\{\w+\}/
        result.each do |matched|
          key = matched[2...-1].downcase.to_sym
          value = value.gsub(matched, @context[key].to_s)
        end
        value
      end

      def scan
        return '' unless scannable?
        result = @invoker.execute(parse @config[:scan])
        result.split "\n"
      end

      def scannable?
        @config[:scan]
      end

      def get_data(config)
        command = parse((config[:command] or '${PATH}:read-resource(include-runtime=true)'))
        result = @invoker.result(command)
        data = []
        config[:properties].each do |prop|
          data << get_property(prop, result)
        end
        data
      end

      def get_property(prop, result)
        value = result
        prop.split(/\s*->\s*/).each do |p|
          value = value[p]
        end
        value
      end

    end
  end
end
