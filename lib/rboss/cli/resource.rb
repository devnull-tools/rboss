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

      attr_accessor :context

      def initialize(invoker, config)
        @config = config
        @invoker = invoker
        @context = {
            :name => '',
            :read_resource => 'read-resource(include-runtime=true,recursive=true,include-defaults=true,proxies=true)'
        }
        @context[:path] = parse(@config[:path])
        @tables = []
        @count = 0
      end

      def invoke(operation, resource_names, arguments)
        if respond_to? operation.to_key
          send operation.to_key, resource_names, arguments
        else
          interact_to_invoke operation, resource_names, arguments
        end
      end

      def read_resource(resources, arguments)
        resources ||= scan
        params = @config[:print]
        return unless params
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
        box = Yummi::TextBox::new
        box.style.border[:color] = 'bold.black'
        width = 0
        @tables.each do |table|
          width = [width, table.width].max
        end
        @tables.each do |table|
          box << table.to_s
          box.add('-' * width, :color => 'bold.black') unless table == @tables.last
        end
        box.to_s
      end

      def read_operation_names(resource_name, arguments)
        operations = ''
        with resource_name do
          result = @invoker.result("#{@context[:path]}:read-operation-names")
          result.each do |operation|
            operations << '- '.bold.magenta
            operations << operation.bold.blue << $/
          end
        end
        operations.on_box
      end

      def read_operation_description (resource_name, arguments)
        buff = ''
        with resource_name do
          operation_name = arguments['name']
          table = Yummi::Table::new
          buff << operation_name.bold.green << $/
          result = @invoker.result(
              "#{@context[:path]}:read-operation-description(name=#{operation_name})"
          )
          buff << result['description'].bold.black << $/ * 2
          table.title = 'Request'
          table.header = %w(Parameter Type Required Default)
          table.aliases = %w(name type required default)
          table.colorize('name', :with => :white)

          table.colorize %w(type default) do |value|
            RBoss::Colorizers.type(value['type']).color_for(value)
          end

          table.format 'required', :using => Yummi::Formatters.boolean
          table.colorize 'required', :using => Yummi::Colorizers.boolean
          result['request-properties'] ||= {}
          unless result['request-properties'].empty?
            result['request-properties'].each do |name, detail|
              detail['name'] = name
              table << detail
            end
            buff << table.to_s << $/
          end

          table = Yummi::Table::new
          table.title = 'Response'
          table.header = %w(Parameter Type Nilable Unit)
          table.aliases = %w(name type nilable unit)

          table.colorize 'name', :with => :white

          table.colorize 'type' do |value|
            RBoss::Colorizers.type(value['type']).color_for(value)
          end

          table.format 'nilable', :using => Yummi::Formatters.boolean
          table.colorize 'nilable', :using => Yummi::Colorizers.boolean
          result['reply-properties'] ||= {}
          unless result['reply-properties'].empty?
            result = result['reply-properties']
            table.description = result['description']
            table << result
            build_nested(result).each do |nested|
              table << nested
            end
            buff << table.to_s << $/
          end
        end
        buff.chomp.on_box
      end

      private

      def build_nested(detail, parent_name = '', result = [])
        if detail['value-type'].respond_to? :each
          detail['value-type'].each do |name, _detail|
            name = "#{parent_name}#{name}"
            _detail['name'] = name
            result << _detail
            build_nested(_detail, "#{name} => ", result)
          end
        end
        result
      end

      def interact_to_invoke(operation, resource_name, arguments)
        with resource_name do
          return @invoker.gets_and_invoke(@context[:path], operation, arguments)
        end
      end

      def with(resources)
        resources ||= ''
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
        table = @tables[@count % @tables.size]
        if data.first.is_a? Array
          table.data = data
        else
          table.add data
        end
        @count += 1
      end

      def parse(value)
        return nil unless value
        result = value.scan(/\$\{\w+\}/)
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
        command = parse((config[:command] or "${PATH}:#{@context[:read_resource]}"))
        begin
          result = @invoker.result(command)
          data = []
          if config[:properties]
            config[:properties].each do |prop|
              data << get_property(prop, result)
            end
          else
            result.each do |name, value|
              data << [name , value]
            end
          end
          data
        rescue
          nil
        end
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
