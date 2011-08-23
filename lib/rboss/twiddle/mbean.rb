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

require_relative 'twiddle'

module JBoss
  class MBean

    attr_reader :pattern
    attr_accessor :resource, :twiddle, :description

    @@__default__detail__resource__ = proc do |resources, &block|
      resouces = _parse_resource_ resources
      details = {}
      resouces.each do |resource|
        with resource do
          details[resource] = {}
          @properties.each do |property|
            details[resource][property] = self[property].value
          end
        end
      end
      details.each &block if block
      details
    end

    @@__default__detail__ = proc do |&block|
      details = {}
      @properties.each do |property|
        details[property] = self[property].value
      end
      details.each &block if block
      details
    end

    def initialize params
      @pattern = params[:pattern]
      @twiddle = params[:twiddle]
      @properties = params[:properties]
      @description = params[:description]
      if params[:scan]
        (class << self
          self
        end).send :define_method, :scan, &params[:scan]
        (class << self
          self
        end).send :define_method, :each do |&block|
          scan.each &block
        end
      end
      if params[:properties]
        (class << self
          self
        end).send :define_method,
                  :detail,
                  &(params[:scan] ?
                      @@__default__detail__resource__ : @@__default__detail__)
      end
    end

    def with resource
      @resource = resource
      if block_given?
        yield
        @resource = nil
      end
      self
    end

    def [] property
      resource = @resource
      query = eval("\"#{pattern}\"")
      result = @twiddle.execute(:get, query, property)

      def result.value
        self.split(/=/)[1]
      end

      result
    end

    def []= property, value
      resource = @resource
      query = eval("\"#{pattern}\"")
      @twiddle.execute :set, query, property, value
    end

    def method_missing(method, *args, &block)
      _invoke_ method, args, block
    end

    def _invoke_ method, *args, &block
      resource = @resource
      query = eval("\"#{pattern} #{method}\"")
      return_value = @twiddle.execute :invoke, query, args
      if block_given?
        block.call return_value
      end
      return_value
    end

    def _query_ query, &block
      result = @twiddle.execute(:query, query)
      return [] unless result
      result = result.split /\s+/
      block ? result.collect(&block) : result
    end

    def _parse_resource_ resources
      return scan if resources == :all
      return [resources] unless resources.respond_to? :each
      resources
    end

  end

end

