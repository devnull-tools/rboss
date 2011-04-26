require_relative "file_processor"
require_relative "file_path_builder"
require_relative "utils"
require_relative "component_processor"
require_relative "command_invoker"
require_relative "jboss"
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

# A Class to configure a JBoss Profile
#
# author Marcelo Guimaraes <ataxexe@gmail.com>
class JBossProfile < ComponentProcessor
  include FileProcessorBuilder, CommandInvoker

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
    @component_processor = ComponentProcessor::new do |type, config|
      type.new(@jboss, @logger, config).process
    end

    @base_dir = FilePathBuilder::new File.dirname(__FILE__)
    @opts = {
      :base_profile => :production,
      :profile => :custom,
      :logger => Logger::new(STDOUT),
    }.merge! opts
    @logger = @opts[:logger]
    @base_profile = @opts[:base_profile].to_s
    @profile = @opts[:profile].to_s
    @jboss = JBoss::new jboss_home, @profile
    @home = @jboss.home
    initialize_components
  end

  def add component, params = {}
    @component_processor.add component, params
  end

  def create
    create_profile
    configure_profile
  end

  def configure_profile
    @component_processor.process_components
  end

  private

  # Creates the instance using the base instance for copying
  def create_profile
    if File.exists? @jboss.instance.to_s
      @logger.info "Removing installed instance"
      invoke "rm -rf #{@jboss.instance}"
    end
    @logger.info "Copying #{@base_profile} to #{@profile}..."
    invoke "cp -r #{@jboss.server @base_profile} #{@jboss.instance}"
  end

  def initialize_components
    @component_processor.register :deploy_folder,

                                  :type => JBossDeployFolder,
                                  :priority => @@install,
                                  :multiple_instances => true

    @component_processor.register :cluster,

                                  :priority => @@install,
                                  :send_config => {
                                    :to_run_conf => [:multicast_ip, :partition_name]
                                  },
                                  :defaults => {
                                    :multicast_ip => "239.255.0.1",
                                    :partition_name => "custom-partition"
                                  }

    @component_processor.register :jms,

                                  :priority => @@install,
                                  :send_config => {
                                    :to_run_conf => [:peer_id]
                                  }

    @component_processor.register :bind,

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

    @component_processor.register :resource,

                                  :type => JBossResource,
                                  :priority => @@after_install,
                                  :multiple_instances => true

    @component_processor.register :jmx,

                                  :type => JBossJMX,
                                  :enabled => true,
                                  :priority => @@setup,
                                  :send_config => {
                                    :to_init_script => {
                                      :password => :jmx_user_password,
                                      :user => :jmx_user
                                    }
                                  }

    @component_processor.register :datasource,

                                  :type => JBossDatasource,
                                  :priority => @@setup,
                                  :multiple_instances => true

    @component_processor.register :xa_datasource,

                                  :type => JBossXADatasource,
                                  :priority => @@setup,
                                  :multiple_instances => true

    @component_processor.register :default_ds,

                                  :type => JBossHypersonicReplacer,
                                  :priority => @@setup

    @component_processor.register :mod_cluster,

                                  :type => JBossModCluster,
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

    @component_processor.register :run_conf,

                                  :type => JBossRunConf,
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

    @component_processor.register :slimming,

                                  :type => JBossSlimming,
                                  :priority => @@slimming,
                                  :defaults => {
                                    :hot_deploy => true
                                  }

    @component_processor.register :init_script,

                                  :type => JBossServiceScript,
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

