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
  class TableBuilder

    def initialize(config)
      @config = config
      add_name_column if config[:scan]
    end

    def add_name_column(name = 'Name')
      @name_column = name
    end

    def show_only_name
      @only_name = true
    end

    def build_table
      table = Yummi::Table::new
      table.title = (@config[:title] or @config[:description])
      header = @config[:header]
      header = [@name_column] + header if @name_column
      if @config[:aliases]
        aliases = @config[:aliases]
        aliases = [:name] + aliases if @name_column
        table.aliases = aliases
      end
      table.header = header
      table.layout = @config[:layout].to_sym if @config[:layout]

      parse_component @config[:format], RBoss::Formatters do |column, params|
        table.format column, params
      end
      parse_component @config[:color], RBoss::Colorizers do |column, params|
        table.colorize column, params
      end
      parse_component @config[:health], RBoss::HealthCheckers do |column, params|
        table.using_row do
          table.colorize column, params
        end
      end

      table.header = [@name_column] if @only_name

      table.format_null :with => 'undefined'
      table.colorize_null :with => :red

      table.colorize :name, :with => :white if @name_column

      table
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

  end

end
