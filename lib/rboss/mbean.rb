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
    attr_accessor :resource, :twiddle

    def initialize params
      @pattern = params[:pattern]
      @twiddle = params[:twiddle]
      @env = @twiddle
    end

    def with resource
      @resource = resource
      self
    end

    def [] property
      resource = @resource
      env = @env
      query = eval("\"#{pattern}\"")
      result = @twiddle.invoke(:get, query, property)
      def result.value
        self.split(/=/)[1]
      end
      result
    end

    def get property, params = {}
      @resource= params[:for]
      self[property]
    end

    def []= property, value
      resource = @resource
      env = @env
      query = eval("\"#{pattern}\"")
      @twiddle.invoke :set, query, property, value
    end

    def method_missing(method, *args, &block)
      _invoke_ method, args, block
    end

    def _invoke_ method, *args, &block
      resource = @resource
      env = @env
      query = eval("\"#{pattern} #{method}\"")
      return_value = @twiddle.invoke :invoke, query, args
      if block_given?
        block.call return_value
      end
      return_value
    end

  end

  module MBeans

    class ServerInfo < MBean

      def initialize twiddle = JBoss::Twiddle::Invoker::new
        super :pattern => 'jboss.system:type=ServerInfo', :twiddle => twiddle
      end

      def free_memory
        get("FreeMemory").value.to_i
      end

      def active_thread_count
        get("ActiveThreadCount").value.to_i
      end

    end

    class Webapps

    end

  end

end

