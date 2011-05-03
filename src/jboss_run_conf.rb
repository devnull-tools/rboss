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

require_relative "jboss_component"

module JBoss

  class RunConf
    include Component

    def initialize jboss, logger, config
      @logger = logger
      @jboss = jboss
      @template_path = config[:path]
      @config = {:args => []}.merge! config
      @args = @config[:args]
      parse_config
    end

    def process
      @logger.info "Creating and configuring run.conf"
      processor = create_file_processor
      processor.with @template_path do |action|
        action.to_process do |content|
          [:heap_size, :perm_size, :stack_size].each do |arg|
            @logger.debug "run.conf: #{arg} -> #{@config[arg]}"
            content.gsub! /\[#{arg.to_s.upcase}\]/, @config[arg].to_s if @config.has_key? arg
          end
          buff = @args.join " "
          unless buff.empty?
            @logger.debug "run.conf: #{buff}"
            content << "\nJAVA_OPTS=\"$JAVA_OPTS #{buff}\""
          end
          content
        end
        processor.copy_to "#{@jboss.profile}/run.conf"
      end
      processor.process
    end

    private

    def parse_config
      {
        :cluster_map => {
          :partition_name => "jboss.partition.name",
          :multicast_ip => "jboss.partition.udpGroup"
        },
        :mod_cluster_map => {
          :advertise => "jboss.mod_cluster.advertise",
          :advertise_group_address => "jboss.mod_cluster.advertise.address",
          :advertise_port => "jboss.mod_cluster.advertise.port",
          :proxy_list => "jboss.mod_cluster.proxyList",
          :excluded_contexts => "jboss.mod_cluster.excludedContexts",
          :auto_enable_contexts => "jboss.mod_cluster.autoEnableContexts"
        },
        :jms_map => {
          :peer_id => "jboss.messaging.ServerPeerID"
        },
        :other => {
          :service_binding => "jboss.service.binding.set"
        }
      }.each { |name, map| merge map }
    end

    def merge map
      (@config.find_all { |key, value| map.has_key? key }).each do |key, value|
        @args << "-D#{map[key]}=#{value}"
        @config.delete key
      end
    end

  end

end
