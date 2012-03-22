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

class TableBuilder

  attr_writer :title

  def initialize params = {}
    params[:colors] ||= {}
    @colors = {
      :title => :yellow,
      :header => :light_blue,
      :good => :green,
      :bad => :red,
      :warn => :brown,
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
    data ||= @data[1]
    type = @types[1]
    format_row(1, type)

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
      format_row(i, type)
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

  def format_row(i, type)
    if @formatter and type != :header
      if @formatter.is_a? Hash
        @formatter[:humanize].each do |index|
          @data[i][index] = humanize @data[i][index]
        end
      else
        @data[i] = @formatter.call(@data[i])
      end
    end
  end

  def check_health
    return unless @health
    @data.each_index do |i|
      if @types[i] == :normal
        row = @data[i]
        if @health.is_a? Hash
          indexes = @health[:indexes]
          @health[:max] = row[indexes[:max]].to_f
          @health[:using] = row[indexes[:using]].to_f if indexes[:using]
          @health[:free] = row[indexes[:free]].to_f if indexes[:free]
          @types[i] = health @health
        else
          @types[i] = @health.call(row)
        end
      end
    end
  end

  def health params
    warn_limit = (params[:warn_at] or 0.3)
    bad_limit = (params[:alert_at] or 0.15)
    return :bad if under_limit? bad_limit, params
    return :warn if warn_limit and under_limit? warn_limit, params
    :good
  end

  def under_limit? threshold, params
    if params[:free]
      free = (params[:free] / params[:max].to_f)
      (free < threshold)
    elsif params[:using]
      free = params[:max] - params[:using]
      under_limit? threshold, :free => free, :max => params[:max]
    end
  end

  def humanize bytes
    bytes = bytes.to_i
    return (bytes / (1024 * 1024)).to_s << " MB" if bytes > (1024 * 1024)
    (bytes / (1024)).to_s << " KB" if bytes > (1024)
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
