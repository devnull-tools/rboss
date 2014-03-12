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
      if @name_column
        @config[:header] ||= []
        @config[:header] = [] if @only_name
        @config[:header] = [@name_column] + @config[:header]
      end

      if @config[:aliases]
        aliases = @config[:aliases]
        aliases = [:name] + aliases if @name_column
        @config[:aliases] = aliases
      end

      builder = Yummi::TableBuilder::new(@config).defaults
      
      builder.repositories[:row_colorizers] << RBoss::HealthCheckers
      builder.repositories[:colorizers] << RBoss::Colorizers
      builder.repositories[:formatters] << RBoss::Formatters

      table = builder.build_table

      table.format_null :with => 'undefined'
      table.colorize_null :with => :red

      table.colorize :name, :with => 'bold.white' if @name_column

      table
    end
    
  end

end
