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

require_relative "file_processor"
require_relative "utils"
require_relative "component_processor"
require_relative "jboss_path"

require "logger"
require "yummi"
require "ostruct"
require "fileutils"

module JBoss

  # A Class to configure a JBoss Profile
  #
  # Basically, this class is a Component Processor with some components added to configure a JBoss profile, the built-in
  # components are:
  #
  # :deploy_folder  => binded to a JBoss::DeployFolder
  #
  # :cluster        => a shortcut component for :run_conf, sends these attributes to it:
  #   :multicast_ip   => default "239.255.0.1"
  #   :partition_name => default "${profile name}-partition
  #
  # :jms            => a shortcut component for :run_conf, sends these attributes to it:
  #   :peer_id
  #
  # :bind           => a shortcut component, sends these attributes:
  #   To :run_conf
  #     :ports        => sends as :service_binding
  #   To :init_script
  #     :address      => default "localhost", sends as :bind_address
  #
  # :resource       => binded to a JBoss::Resource
  #
  # :jmx            => binded to a JBoss::JMX, enabled by default and sends user and password
  #                    values to :init_script
  #
  # :datasource     => binded to a JBoss::Datasource
  #
  # :xa_datasource  => binded to a JBoss::XADatasource
  #
  # :default_ds     => binded to a JBoss::HypersonicReplacer
  #
  # :mod_cluster    => binded to a JBoss::ModCluster
  #   Defaults:
  #     :path => "resources/mod_cluster.sar"
  #   Move to :run_conf (for externalizing mod_cluster configuration)
  #     :advertise
  #     :advertise_group_address
  #     :advertise_port
  #     :proxy_list
  #     :excluded_contexts
  #     :auto_enable_contexts
  #
  # :run_conf       => binded to a JBoss::RunConf
  #   Defaults:
  #     :path => 'resources/run.conf.erb'
  #     :stack_size => '128k'
  #     :heap_size => '2048m'
  #     :perm_size => '256m'
  #
  # :slimming       => binded to a JBoss::Slimming
  #
  # :init_script    => binded to a JBoss::ServiceScritp
  #   Defaults:
  #     :path => 'resources/jboss_init_redhat.sh'
  #     :jmx_user => "admin"
  #     :jmx_password => "admin"
  #     :bind_address => "0.0.0.0"
  #     :java_path => "/usr/java/default"
  #     :jnp_port => 1099
  #     :jboss_user => "RUNASIS"
  #
  # author Marcelo Guimarães <ataxexe@gmail.com>
  class Profile < ComponentProcessor

    # Priorities for components
    @@pre_install = 0
    @@install = @@pre_install + 10
    @@post_install = @@install + 10

    @@pre_setup = @@post_install + 10
    @@setup = @@pre_setup + 10
    @@post_setup = @@setup + 10

    @@final = @@post_setup + 10

    attr_reader :jboss

    def initialize opts = {}
      block = lambda { |type, config| type.new(@jboss, @logger, config).process }
      super &block
      @base_dir = File.dirname(__FILE__)
      @opts = {
        :jboss_home => ENV['JBOSS_HOME'],
        :base_profile => :production,
        :profile => :custom,
        :type => :undefined,
        :version => :undefined
      }.merge! opts
      @jboss_home = File.expand_path @opts[:jboss_home]
      @logger = @opts[:logger]
      unless @logger
        @logger = Logger::new STDOUT
        @logger.level = opts[:log_level] || Logger::INFO
        formatter = Yummi::Formatter::LogFormatter.new do |severity, message|
          "#{severity} : #{message}"
        end

        @logger.formatter = formatter
      end
      @profile = @opts[:profile].to_s
      @base_profile = @opts[:base_profile].to_s
      @jboss = JBoss::Path::new @jboss_home,
                                :profile => @profile,
                                :type => @opts[:type],
                                :version => @opts[:version],
                                :logger => @logger
      initialize_components
    end

    def create
      add :profile_folder, @base_profile
      process_components
    end

    alias update process_components

    # For making code more readable
    #
    # example: profile.install :mod_cluster
    alias install add

    # For making code more readable
    #
    # example: profile.configure :jmx, :password => "password"
    alias configure add

    # For making code more readable
    #
    # example: profile.slim :jmx_console, :admin_console
    def slim *args
      add :slimming, args
    end

    # loads extensions to components based on the type of jboss (eap, soa-p, org, epp...)
    def load_extensions
      unless @jboss.type == :undefined
        dir = File.join(@base_dir, "components", @jboss.type.to_s.gsub(/_/, '-'))
        load_scripts_in dir
        unless @jboss.version == :undefined
          dir = File.join(dir, @jboss.version.to_s)
          load_scripts_in dir
        end
      end
    end

    def load_scripts_in dir
      if File.exists? dir
        scripts = Dir.entries(dir).find_all { |f| f.end_with? '.rb' }
        scripts.each do |script|
          load File.join(dir, script)
        end
      end
    end

    # Loads manually every script related to jboss. This is necessary to reset the components to its natural state
    def load_scripts
      scripts = Dir.entries("#{@base_dir}/components").find_all { |f| f.end_with?('.rb') }
      scripts.each do |script|
        load File.expand_path(@base_dir) + "/components/" + script
      end
    end

    def initialize_components
      load_scripts
      load_extensions

      register :cluster,

               :priority => @@pre_install,
               :move_config => {
                 :to_run_conf => [:multicast_ip, :partition_name],
                 :to_jboss_web => [:jvm_route],
                 :to_jms => [:peer_id]
               },
               :defaults => {
                 :multicast_ip => "239.255.0.1",
                 :partition_name => "#{@profile}-partition",
                 :jvm_route => "#{@profile}"
               }

      register :jms,

               :priority => @@pre_install,
               :move_config => {
                 :to_run_conf => [:peer_id]
               }

      register :bind,

               :priority => @@pre_install,
               :send_config => {
                 :to_init_script => {
                   :address => :bind_address
                 }
               },
               :move_config => {
                 :to_run_conf => {
                   :ports => :service_binding
                 }
               },
               :defaults => {
                 :address => 'localhost'
               }

      register :profile_folder,
               :type => JBoss::ProfileFolder,
               :priority => @@install

      register :deploy_folder,

               :type => JBoss::DeployFolder,
               :priority => @@post_install,
               :multiple_instances => true


      register :resource,

               :type => JBoss::Resource,
               :priority => @@pre_setup,
               :multiple_instances => true

      register :jmx,

               :type => JBoss::JMX,
               :priority => @@setup,
               :send_config => {
                 :to_init_script => {
                   :password => :jmx_password,
                   :user => :jmx_user
                 }
               }

      register :datasource,

               :type => JBoss::Datasource,
               :priority => @@setup,
               :multiple_instances => true

      register :xa_datasource,

               :type => JBoss::XADatasource,
               :priority => @@setup,
               :multiple_instances => true

      register :default_ds,

               :type => JBoss::HypersonicReplacer,
               :priority => @@setup

      register :mod_cluster,

               :type => JBoss::ModCluster,
               :priority => @@setup,
               :move_config => {
                 :to_run_conf => [
                   :advertise,
                   :advertise_group_address,
                   :advertise_port,
                   :proxy_list,
                   :excluded_contexts,
                   :auto_enable_contexts
                 ]
               },
               :defaults => {
                 :path => "#{@base_dir}/resources/mod_cluster.sar",
               }

      register :jbossweb,

               :type => JBoss::JBossWeb,
               :priority => @@setup

      register :run_conf,

               :type => JBoss::RunConf,
               :priority => @@post_setup,
               :send_config => {
                 :to_init_script => [:service_binding]
               },
               :defaults => {
                 :template_path => "#{@base_dir}/resources/run.conf.erb",

                 :stack_size => '128k',
                 :heap_size => '2048m',
                 :perm_size => '256m'
               }

      register :slimming,

               :type => JBoss::Slimming,
               :priority => @@post_setup

      register :restore,

               :type => JBoss::Restore,
               :priority => @@post_setup + 5

      register :init_script,

               :type => JBoss::ServiceScript,
               :priority => @@final,
               :defaults => {
                 :path => "#{@base_dir}/resources/jboss_init_redhat.sh.erb",
                 :jmx_user => "admin",
                 :jmx_password => "admin",
                 :bind_address => "0.0.0.0",
                 :java_path => "/usr/java/default",
                 :jnp_port => 1099,
                 :jboss_user => "RUNASIS"
               }
    end

  end

end
