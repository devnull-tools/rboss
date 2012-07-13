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
          :name => ''
        }
        @context[:path] = parse(@config[:path])
        @tables = []
        @count = 0
      end

      def content(resources)
        if :all == resources
          resources = scan
        end
        resources = [resources] unless resources.is_a? Array
        params = @config[:print]
        params.each do |p|
          table_builder = RBoss::TableBuilder::new p
          table_builder.add_name_column if scannable?
          @tables << table_builder.build_table
        end
        resources.each do |resource|
          @context[:name] = resource
          @context[:path] = parse(@config[:path])

          params.each do |p|
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
          value = value.gsub(matched, @context[key])
        end
        value
      end

      def scan
        result = @invoker.execute(parse @config[:scan])
        result.split "\n"
      end

      def scannable?
        @config[:scan]
      end

      def get_data(config)
        result = @invoker.execute(parse config[:command])
        result = eval_result(result)
        data = []
        config[:properties].each do |prop|
          data << get_property(prop, result)
        end
        data
      end

      def get_property(prop, result)
        value = result["result"]
        prop.split(/\s*->\s*/).each do |p|
          value = value[p]
        end
        value
      end

      def eval_result(result)
        undefined = nil #prevents error because undefined means nil in result object
        result = result.gsub /(\d+)L/, '\1' #removes the long type mark
        eval(result)
      end

    end
  end
end
