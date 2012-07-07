module JBoss
  module Cli
    class Component

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

        methods = @config.select do |key, value|
          key.to_s.start_with? 'print_'
        end
        params = (methods.collect { |k, v| v }).flatten
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
        end
      end

      def add_row(params)
        data = get_data(params)
        return unless data
        data = [@context[:name]] + data if @config[:scan]
        @tables[@count % @tables.size].data << data
        @count += 1
      end

      def parse(value)
        result = value.scan /\[\w+\]/
        result.each do |matched|
          key = matched[1...-1].downcase.to_sym
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
        header = %w(Name) + header if @config[:scan]
        table.header = header

        table
      end

      def get_data(config)
        result = @invoker.execute(parse config[:command])
        undefined = nil #prevents error because undefined means nil in result object
        result = eval(result)
        data = []
        config[:properties].each do |prop|
          data << result["result"][prop]
        end
        data
      end

    end
  end
end
