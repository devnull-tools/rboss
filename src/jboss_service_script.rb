require_relative "jboss_component"

module JBoss

  class ServiceScript
    include Component

    def initialize jboss, logger, config
      @logger = logger
      @jboss = jboss
      @template_path = config.delete :path
      @config = config
      @config[:configuration] = @jboss.profile_name
      @config[:jboss_home] = @jboss.home
    end

    def process
      @logger.info "Configuring service script..."
      processor = create_file_processor
      processor.with @template_path do |action|
        action.to_process do |content|
          [
            :jmx_user,
            :jmx_password,
            :jnp_port,
            :jboss_home,
            :jboss_user,
            :java_path,
            :configuration,
            :bind_address].each do |arg|
            @logger.debug "init script: #{arg} -> #{@config[arg]}"
            content.gsub! /\[#{arg.to_s.upcase}\]/, @config[arg].to_s if @config.has_key? arg
          end
          content
        end
        processor.copy_to @jboss.bin("jboss_init_#{@jboss.profile_name}.sh")
      end
      processor.process
    end

  end
end
