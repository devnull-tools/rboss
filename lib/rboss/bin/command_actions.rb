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

require 'wirble'

module JBoss
  module CommandActions
    class Twiddle

      def initialize twiddle, opts = {}
        @monitor = twiddle.monitor
        @twiddle = twiddle
        @opts = opts
      end

      def parse_and_execute commands
        commands.each do |method, args|
          send method, *args
        end
      end

      def native command
        puts @twiddle.execute(command)
      end

      def set id, property, value
        mbean, name = extract id
        puts @twiddle.set :mbean => mbean.to_sym,
                          :name => name,
                          :property => property,
                          :value => value
      end

      def get id, property
        mbean, name = extract id
        puts @twiddle.get :mbean => mbean.to_sym,
                          :name => name,
                          :property => property
      end

      def invoke id, method, *args
        mbean, name = extract id
        puts @twiddle.invoke :mbean => mbean.to_sym,
                             :name => name,
                             :method => method,
                             :args => normalize(args)
      end

      def query id, *args
        mbean, name = extract id
        puts @twiddle.query :mbean => mbean.to_sym,
                            :name => name,
                            :args => normalize(args)
      end

      def info id, *args
        mbean, name = extract id
        puts @twiddle.info :mbean => mbean.to_sym,
                           :name => name,
                           :args => normalize(args)
      end

      def detail mbeans
        mbeans.each do |mbean_id, resources|
          table = TableBuilder::new @opts[:mbeans][mbean_id]
          table.title = @opts[:mbeans][mbean_id][:description]
          rows = []
          if resources.is_a? TrueClass
            row = []
            @monitor.mbean(mbean_id).detail do |name, value|
              row << value
            end
            rows << row
          elsif @opts[:no_details]
            @monitor.mbean(mbean_id).scan.each do |name|
              puts "    - #{name}"
            end
          else
            @monitor.mbean(mbean_id).detail resources do |resource, detail|
              row = [resource]
              detail.each do |name, value|
                row << value
              end
              rows << row
            end
          end
          rows.each { |row| table.add :normal, *row }
          table.print
        end
      end

    end

    class TableBuilder

      attr_writer :title

      def initialize params = {}
        params[:colors] ||= {}
        @colors = {
          :title => :yellow,
          :header => :light_blue,
          :good => :green,
          :bad => :red,
          :warn => :gray,
          :line => :purple,
          :normal => nil
        }.merge! params[:colors]
        @health = params[:health]
        @header = params[:header]
        @formatter = params[:formatter]
        @print_type = (params[:print_as] or :table)
        @single_result = params[:single_result]

        @data = []
        @types = []
        @title = nil
      end

      def add(type, *args)
        @types << type
        @data << args
      end

      def print
        build_header @header
        check_health
        puts colorize(:title, @title)
        print_as_table if @print_type == :table
        print_as_single_list if @print_type == :single_list
      end

      def print_as_single_list
        header = @data[0]
        data = @formatter.call(@data[1]) if @formatter
        data ||= @data[1]
        type = @types[1]

        line = colorize :line, '-'
        data.each_index do |i|
          description = colorize :header, header[i]
          value = colorize type, data[i]
          puts "  #{line} #{description} = #{value}"
        end
      end

      def print_as_table colspan = 2
        @data.each_index do |i|
          type = @types[i]
          @data[i] = @formatter.call(@data[i]) if @formatter and type != :header
          @data[i].each_index do |j|
            column = @data[i][j]
            width = max_width j
            value = column.to_s.ljust(width) if j == 0
            value ||= column.to_s.rjust(width)
            printf colorize(type, value)
            printf(" " * colspan)
          end
          puts
        end
      end

      def check_health
        return unless @health
        @data.each_index do |i|
          if @types[i] == :normal
            row = @data[i]
            @types[i] = @health.call(row)
          end
        end
      end

      def build_header header
        return unless header
        if header.is_a? Array
          if header.first.is_a? Array
            header.reverse.each do |value|
              build_header value
            end
          else
            @data = [header] + @data
            @types = [:header] + @types
          end
        end
      end

      def colorize(type, value)
        Wirble::Colorize::colorize_string(value, @colors[type])
      end

      def max_width column
        max = 0
        @data.each do |row|
          max = [row[column].to_s.length, max].max
        end
        max
      end

    end

  end

end
