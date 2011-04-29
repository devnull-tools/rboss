require_relative "file_processor"
require_relative "file_path_builder"
require_relative "utils"
require_relative "component_processor"
require_relative "command_invoker"
require_relative "jboss_path"
require_relative "jboss_jmx"
require_relative "jboss_resource"
require_relative "jboss_slimming"
require_relative "jboss_deploy_folder"
require_relative "jboss_datasource"
require_relative "jboss_xadatasource"
require_relative "jboss_hypersonic_replacer"
require_relative "jboss_mod_cluster"
require_relative "jboss_run_conf"
require_relative "jboss_service_script"

require "logger"
require "ostruct"
require "fileutils"

module JBoss

  # A Class to configure a JBoss Profile
  #
  # author Marcelo Guimaraes <ataxexe@gmail.com>
  class Profile < ComponentProcessor
    include CommandInvoker

    # Priorities for components
    @@install = 0
    @@after_install = 5

    @@before_setup = 10
    @@setup = 15
    @@after_setup = 20

    @@before_tunning = 25
    @@tunning = 30
    @@after_tunning = 35

    @@before_slimming = 40
    @@slimming = 45
    @@after_slimming = 50

    @@final = 55

    attr_reader :home

    def initialize jboss_home, opts = {}
      block = lambda { |type, config| type.new(@jboss, @logger, config).process }
      super &block
      @base_dir = FilePathBuilder::new File.dirname(__FILE__)
      @opts = {
        :base_profile => :production,
        :profile => :custom,
        :logger => Logger::new(STDOUT),
      }.merge! opts
      @logger = @opts[:logger]
      @base_profile = @opts[:base_profile].to_s
      @profile = @opts[:profile].to_s
      @jboss = JBoss::Path::new jboss_home, @profile
      @home = @jboss.home
      initialize_components
    end

    def create
      create_profile
      configure_profile
    end

    def configure_profile
      process_components
    end

    private

    # Creates the profile using the base profile for copying
    def create_profile
      if File.exists? @jboss.profile.to_s
        @logger.info "Removing installed profile"
        invoke "rm -rf #{@jboss.profile}"
      end
      @logger.info "Copying #{@base_profile} to #{@profile}..."
      invoke "cp -r #{@jboss.server @base_profile} #{@jboss.profile}"
    end

    def initialize_components
      register :deploy_folder,

               :type => JBoss::DeployFolder,
               :priority => @@install,
               :multiple_instances => true

      register :cluster,

               :priority => @@install,
               :send_config => {
                 :to_run_conf => [:multicast_ip, :partition_name]
               },
               :defaults => {
                 :multicast_ip => "239.255.0.1",
                 :partition_name => "custom-partition"
               }

      register :jms,

               :priority => @@install,
               :send_config => {
                 :to_run_conf => [:peer_id]
               }

      register :bind,

               :priority => @@install,
               :send_config => {
                 :to_init_script => {
                   :address => :bind_address
                 },
                 :to_run_conf => {
                   :ports => :service_binding
                 }
               },
               :defaults => {
                 :address => 'localhost'
               }

      register :resource,

               :type => JBoss::Resource,
               :priority => @@after_install,
               :multiple_instances => true

      register :jmx,

               :type => JBoss::JMX,
               :enabled => true,
               :priority => @@setup,
               :send_config => {
                 :to_init_script => {
                   :password => :jmx_password,
                   :user => :jmx_user
                 }
               },
               :defaults => {
                 :user => "admin",
                 :password => "admin"
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
                 :path => @base_dir.resources('mod_cluster.sar'),
               }

      register :run_conf,

               :type => JBoss::RunConf,
               :priority => @@after_setup,
               :enabled => true,
               :send_config => {
                 :to_init_script => [:service_binding]
               },
               :defaults => {
                 :path => @base_dir.resources('run.conf'),
                 :stack_size => '128k',
                 :heap_size => '2048m',
                 :perm_size => '256m',
               }

      register :slimming,

               :type => JBoss::Slimming,
               :priority => @@slimming,
               :defaults => {
                 :hot_deploy => true
               }

      register :init_script,

               :type => JBoss::ServiceScript,
               :priority => @@final,
               :defaults => {
                 :path => @base_dir.resources('jboss_init_redhat.sh'),
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
