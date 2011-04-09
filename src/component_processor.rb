class ComponentProcessor

  def register component, params
    @components ||= {}
    params[:configs] ||= [] if params[:multiple_instances]
    params[:defaults] ||= {}
    @components[component] = params unless @components.has_key? component
  end

  def add component, config = {}
    registered_component = @components[component]
    return unless registered_component
    defaults = registered_component[:defaults]
    registered_component[:enabled] = true
    config = defaults.merge config
    if registered_component[:multiple_instances]
      registered_component[:configs] << config
    else
      registered_component[:config] = config
    end
  end

  def process_components
    (@components.sort_by { |key, value| value[:priority] }).each do |key, component|
      next unless component[:enabled]
      process_component component
    end
  end

  private

  def process_component component
    #TODO refactor this -----------------------------------
    if component[:send_config]
      component[:send_config].each do |to, keys|
        destination = to.to_s.gsub(/^to_/, '').to_sym
        config = {}
        if keys.is_a? Array
          keys.each do |key|
            config[key] = component[:defaults][key] if component[:defaults].has_key? key
          end
        elsif keys.is_a? Hash
          keys.each do |k, v|
            config[v] = component[:defaults][k] if component[:defaults].has_key? k
          end
        end
        send_config destination, config
      end
    end
    if component[:move_config]
      component[:move_config].each do |to, keys|
        destination = to.to_s.gsub(/^to_/, '').to_sym
        config = {}
        if keys.is_a? Array
          keys.each do |key|
            config[key] = component[:config].delete key if component[:config].has_key? key
          end
        elsif keys.is_a? Hash
          keys.each do |k, v|
            config[v] = component[:config].delete k if component[:config].has_key? k
          end
        end
        send_config destination, config
      end
    end
    #------------------------------------------------------
    return unless component[:type]
    if component[:multiple_instances]
      component[:configs].each do |config|
        component[:type]::new(@jboss, @logger, config).process
      end
    else
      config = component[:config]
      config ||= component[:defaults]
      component[:type]::new(@jboss, @logger, config).process
    end
  end

  def send_config component, config
    component_config = @components[component][:config]
    return unless component_config
    if component_config.is_a? Array
      component_config.each { |c| c.merge! config }
    end
    component_config.merge! config if component_config.is_a? Hash
  end


end
