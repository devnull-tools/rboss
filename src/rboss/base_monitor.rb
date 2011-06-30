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

require_relative 'monitor'
require_relative 'twiddle'

module JBoss
  module Twiddle

    class BaseMonitor
      include JBoss::Twiddle::Monitor

      attr_reader :twiddle

      def defaults
        {
          :webapp => {
            :pattern => 'jboss.web:type=Manager,host=localhost,path=/#{resource}',
            :properties => %W(activeSessions maxActive)
          },
          :connector => {
            :pattern => 'jboss.web:type=ThreadPool,name=#{resource.split(/:/)[0]}-#{env.jboss_ip}-#{@resource.split(/:/)[1]}',
            :properties => %W(maxThreads currentThreadCount currentThreadsBusy)
          },
          :server_info => {
            :pattern => 'jboss.system:type=ServerInfo',
            :properties => %W(FreeMemory ActiveThreadCount)
          },
          :request => {
            :pattern => 'jboss.web:type=GlobalRequestProcessor,name=#{resource.split(/:/)[0]}-#{env.jboss_ip}-#{@resource.split(/:/)[1]}',
            :properties => %W(requestCount)
          },
          :datasource => {
            :pattern => 'jboss.jca:service=ManagedConnectionPool,name=#{resource}',
            :properties => %W(MaxSize AvailableConnectionCount InUseConnectionCount ConnectionCount)
          }
        }
      end

      def initialize params = {}
        @twiddle = JBoss::Twiddle::Invoker::new params
        defaults.each do |mbean_id, config|
          monitor mbean_id, config
        end
      end

    end

  end

end
