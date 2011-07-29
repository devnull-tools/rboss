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

module JBoss
  module Twiddle
    module Scanner

      def webapps
        _query_ "jboss.web:type=Manager,*" do |path|
          path.gsub! "jboss.web:type=Manager,path=/", ""
          path.gsub! /,host=.+/, ''
          path
        end
      end

      def datasources
        _query_ "jboss.jca:service=ManagedConnectionPool,*" do |path|
          path.gsub "jboss.jca:service=ManagedConnectionPool,name=", ""
        end
      end

      def connectors
        _query_ "jboss.web:type=ThreadPool,*" do |path|
          path.gsub "jboss.web:type=ThreadPool,name=", ""
        end
      end

      def queues
        _query_ "jboss.messaging.destination:service=Queue,*" do |path|
          path.gsub "jboss.messaging.destination:service=Queue,name=", ""
        end
      end

      def deployments
        _query_ "jboss.web.deployment:*" do |path|
          path.gsub "jboss.web.deployment:", ""
        end
      end

      def can_scan? resource
        self.respond_to? resource.to_sym
      end

      private

      def _query_ query, &block
        result = @twiddle.invoke(:query, query).split /\s+/
        block ? result.collect(&block) : result
      end

    end
  end
end
