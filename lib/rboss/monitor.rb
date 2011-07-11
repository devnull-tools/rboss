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

require_relative 'mbean'

module JBoss
  module Twiddle

    module Monitor

      def discoverer
        @discoverer ||= JBoss::Twiddle::Scanner::new @twiddle
        @discoverer
      end

      def properties
        @properties ||= {}
        @properties
      end

      def mbeans
        @mbeans ||= {}
        @mbeans
      end

      def resources mbean_id = nil, *resources
        @resources ||= {}
        return @resources unless mbean_id
        return @resources[mbean_id] unless resources
        if mbean_id.is_a? Array
          mbean_id.each do |id|
            @resources[id] = resources
          end
        else
          @resources[mbean_id] = resources
        end
      end

      def monitor mbean_id, params
        mbeans[mbean_id] = JBoss::MBean::new :pattern => params[:pattern], :twiddle => @twiddle
        properties[mbean_id] = params[:properties]
      end

      def with resource
        resource = discoverer.send resource if resource.is_a? Symbol
        if block_given?
          if resource.kind_of? Array
            resource.each do |res|
              @current_resource = res
              yield res
              @current_resource = nil
            end
          else
            @current_resource = resource
            yield
            @current_resource = nil
          end
        end
      end

      def value_for mbean_id, params = @current_resource
        mbean = mbeans[mbean_id]
        if params.is_a? Hash
          resource = params[:resource]
          property = params[:property]
          mbean.get property, :for => resource
        else
          resource = params
          mbean.with resource
        end
      end

      def [] mbean_id
        mbean = mbeans[mbean_id]
        if @current_resource
          mbean.with resource
        end
        mbean
      end

      def method_missing(method, *args, &block)
        value_for method, *args
      end

    end

  end

end
