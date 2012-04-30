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

require 'yummi'

class TableBuilder

  def initialize params = {}
    @params = params
    @table = Yummi::Table::new
    @table.title = params[:description]
    @table.header = params[:header]
    if params[:layout] == :vertical
      @table.layout = :vertical
      @table.default_align = :left
    end
    if params[:health]
      @table.row_colorizer HealthColorizer::new params[:health]
    end
    if params[:formatter]
      params[:formatter].each do |column|
        @table.format column do |value|
          Yummi::Formatter::Unit.format :byte, value.to_i
        end
      end
    end
  end

  def no_details
    @table.header = @params[:header][0]
  end

  def data= data
    @table.data = data
  end

  def table
    @table
  end

end

class HealthColorizer

  def initialize params
    @max = params[:max]
    @free = params[:free]
    @using = params[:using]
  end

  def call index, data
    max = data[@max].to_f
    free = @using ? max - data[@using].to_f : data[@free].to_f

    percentage = free / max

    return :red if percentage <= 0.15
    return :brown if percentage <= 0.30
    :green
  end

end
