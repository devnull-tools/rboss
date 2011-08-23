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

      def defaults
        @@defaults ||= {
          :webapp => {
            :description => 'Deployed webapps',
            :pattern => 'jboss.web:type=Manager,host=localhost,path=/#{resource}',
            :properties => %W(activeSessions maxActive),
            :scan => proc do
              _query_ "jboss.web:type=Manager,*" do |path|
                path.gsub! "jboss.web:type=Manager,path=/", ""
                path.gsub! /,host=.+/, ''
                path
              end
            end
          },
          :web_deployment => {
            :description => 'Deployed webapp control',
            :pattern => 'jboss.web.deployment:war=/#{resource}'
          },
          :connector => {
            :description => 'JBossWeb connector',
            :pattern => 'jboss.web:type=ThreadPool,name=#{resource}',
            :properties => %W(maxThreads currentThreadCount currentThreadsBusy),
            :scan => proc do
              _query_ "jboss.web:type=ThreadPool,*" do |path|
                path.gsub "jboss.web:type=ThreadPool,name=", ""
              end
            end
          },
          :engine => {
            :description => 'JBossWeb engine',
            :pattern => 'jboss.web:type=Engine',
            :properties => %W(jvmRoute name defaultHost)
          },
          :server_info => {
            :description => 'JBoss running info',
            :pattern => 'jboss.system:type=ServerInfo',
            :properties => %W(ActiveThreadCount MaxMemory FreeMemory AvailableProcessors
                              HostAddress JavaVendor JavaVersion OSName OSArch)
          },
          :server => {
            :description => 'JBoss specifications',
            :pattern => 'jboss.system:type=Server',
            :properties => %W(VersionNumber StartDate)
          },
          :system_properties => {
            :description => 'System properties',
            :pattern => 'jboss:name=SystemProperties,type=Service'
          },
          :request => {
            :description => 'JBossWeb connector requests',
            :pattern => 'jboss.web:type=GlobalRequestProcessor,name=#{resource}',
            :properties => %W(requestCount errorCount maxTime),
            :scan => proc do
              _query_ "jboss.web:type=ThreadPool,*" do |path|
                path.gsub "jboss.web:type=ThreadPool,name=", ""
              end
            end
          },
          :datasource => {
            :description => 'Datasource',
            :pattern => 'jboss.jca:service=ManagedConnectionPool,name=#{resource}',
            :properties => %W(MinSize MaxSize AvailableConnectionCount
                                InUseConnectionCount ConnectionCount),
            :scan => proc do
              _query_ "jboss.jca:service=ManagedConnectionPool,*" do |path|
                path.gsub "jboss.jca:service=ManagedConnectionPool,name=", ""
              end
            end
          },
          :queue => {
            :description => 'JMS Queue',
            :pattern => 'jboss.messaging.destination:service=Queue,name=#{resource}',
            :properties => %W(Name JNDIName MessageCount DeliveringCount
              ScheduledMessageCount MaxSize FullSize Clustered ConsumerCount),
            :scan => proc do
              _query_ "jboss.messaging.destination:service=Queue,*" do |path|
                path.gsub "jboss.messaging.destination:service=Queue,name=", ""
              end
            end
          },
          :ejb => {
            :description => 'EJB',
            :pattern => 'jboss.j2ee:#{resource},service=EJB3',
            :properties => %W(CreateCount RemoveCount CurrentSize AvailableCount),
            :scan => proc do
              result = _query_ "jboss.j2ee:*"
              (result.find_all do |path|
                path["service=EJB3"] && path["name="] && path["jar="]
              end).collect do |path|
                path.gsub("jboss.j2ee:", '').gsub(/,?service=EJB3/, '')
              end
            end
          }
        }
        @@defaults
      end

      module_function :defaults

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
        mbeans[mbean_id] = JBoss::MBean::new params.merge(:twiddle => @twiddle)
      end

      def with resource
        resource = send resource if resource.is_a? Symbol
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

      def mbean mbean_id
        mbean = mbeans[mbean_id]
        if @current_resource
          mbean.with @current_resource
        end
        mbean
      end

      def method_missing method, *args, &block
        mbean_id = method
        mbean = mbeans[mbean_id]
        resource = args[0] || @current_resource
        mbean.with resource
      end

    end

  end

end
