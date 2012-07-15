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

require_relative 'mbean'

module RBoss
  module Twiddle

    module Monitor

      def defaults
        @@defaults ||= {
          :webapp => {
            :description => 'Deployed webapps',
            :pattern => 'jboss.web:type=Manager,host=localhost,path=/#{resource}',
            :properties => %W(activeSessions maxActive distributable maxActiveSessions
                                    expiredSessions rejectedSessions),
            :header => ["Active\nSessions", "Max\nSessions", "Distributable",
                        "Max Active\nSession", "Expired\nSessions", "Rejected\nSessions"],
            :scan => proc do
              query "jboss.web:type=Manager,*" do |path|
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
            :header => ['Max Threads', 'Current Threads', 'Busy Threads'],
            :health => {
              :current_threads => {
                :component => :percentage,
                :params => {
                  :max => :max_threads,
                  :using => :current_threads
                }
              }
            },
            :scan => proc do
              query "jboss.web:type=ThreadPool,*" do |path|
                path.gsub "jboss.web:type=ThreadPool,name=", ""
              end
            end
          },
          :cached_connection_manager => {
            :description => 'JBoss JCA cached connections',
            :pattern => 'jboss.jca:service=CachedConnectionManager',
            :properties => %W(InUseConnections),
            :header => ['In Use Connections'],
          },
          :main_deployer => {
            :description => 'Main Deployer',
            :pattern => 'jboss.system:service=MainDeployer'
          },
          :engine => {
            :description => 'JBossWeb engine',
            :pattern => 'jboss.web:type=Engine',
            :properties => %W(jvmRoute name defaultHost),
            :header => ['JVM Route', 'Name', 'Default Host'],
          },
          :log4j => {
            :description => 'JBoss Log4J Service',
            :pattern => 'jboss.system:service=Logging,type=Log4jService',
            :properties => %W(DefaultJBossServerLogThreshold),
            :header => ['Default Server Log Threshold'],
          },
          :server => {
            :description => 'JBoss Server specifications',
            :pattern => 'jboss.system:type=Server',
            :properties => %W(VersionName VersionNumber Version),
            :layout => :vertical,
            :header => ['Version Name', 'Version Number', 'Version'],
          },
          :server_info => {
            :description => 'JBoss Server runtime info',
            :pattern => 'jboss.system:type=ServerInfo',
            :properties => %W(ActiveThreadCount MaxMemory FreeMemory AvailableProcessors
                                    JavaVendor JavaVersion OSName OSArch),
            :header => ["Active Threads", "Max Memory", "Free Memory",
                        "Processors", "Java Vendor", "Java Version", "OS Name", "OS Arch"],
            :layout => :vertical,
            :format => {
              :max_memory => {:component => :byte},
              :free_memory => {:component => :byte}

            },
            :health => {
              :free_memory => {
                :component => :percentage,
                :params => {
                  :max => :max_memory,
                  :free => :free_memory
                }
              }
            }
          },
          :server_config => {
            :description => 'JBoss Server configuration',
            :pattern => 'jboss.system:type=ServerConfig',
            :properties => %W(ServerName HomeDir ServerLogDir ServerHomeURL),
            :layout => :vertical,
            :header => ['Server Name', 'Home Dir', 'Log Dir', 'Home URL'],
          },
          :system_properties => {
            :description => 'System properties',
            :pattern => 'jboss:name=SystemProperties,type=Service'
          },
          :request => {
            :description => 'JBossWeb connector requests',
            :pattern => 'jboss.web:type=GlobalRequestProcessor,name=#{resource}',
            :properties => %W(requestCount errorCount maxTime),
            :header => ['Requests', 'Errors', 'Max Time'],
            :health => {
              :errors => {
                :component => :percentage,
                :params => {
                  :max => :requests,
                  :using => :errors
                }
              }
            },
            :scan => proc do
              query "jboss.web:type=ThreadPool,*" do |path|
                path.gsub "jboss.web:type=ThreadPool,name=", ""
              end
            end
          },
          :datasource => {
            :description => 'Datasource',
            :pattern => 'jboss.jca:service=ManagedConnectionPool,name=#{resource}',
            :properties => %W(MinSize MaxSize AvailableConnectionCount
                                      InUseConnectionCount ConnectionCount),
            :header => ["Min\nSize", "Max\nSize", "Avaliable\nConnections",
                        "In Use\nConnections", "Connection\nCount"],
            :health => {
              :in_use_connections => {
                :component => :percentage,
                :params => {
                  :max => :max_size,
                  :using => :in_use_connections
                }
              }
            },
            :scan => proc do
              query "jboss.jca:service=ManagedConnectionPool,*" do |path|
                path.gsub "jboss.jca:service=ManagedConnectionPool,name=", ""
              end
            end
          },
          :queue => {
            :description => 'JMS Queue',
            :pattern => 'jboss.messaging.destination:service=Queue,name=#{resource}',
            :properties => %W(JNDIName MessageCount DeliveringCount
                    ScheduledMessageCount MaxSize FullSize Clustered ConsumerCount),
            :header => ['JNDI Name', 'Messages', 'Deliveries', 'Scheduleded', 'Max Size',
                        'Full Size', 'Clustered', 'Consumed'],
            :scan => proc do
              query "jboss.messaging.destination:service=Queue,*" do |path|
                path.gsub "jboss.messaging.destination:service=Queue,name=", ""
              end
            end
          },
          :jndi => {
            :description => 'JNDI View',
            :pattern => 'jboss:service=JNDIView'
          }
        }
      end

      module_function :defaults

      def mbeans
        @mbeans ||= {}
      end

      def monitor(mbean_id, params)
        mbeans[mbean_id] = RBoss::MBean::new params.merge(:twiddle => @twiddle)
      end

      def mbean(mbean_id)
        mbean = mbeans[mbean_id]
        return RBoss::MBean::new :pattern => mbean_id.to_s, :twiddle => @twiddle unless mbean
        if @current_resource
          mbean.with @current_resource
        end
        mbean
      end

    end

  end

end

