# A main class to process components based on a highly customizable set of parameters.
# A processable component is anything that can be configurated by a Hash.
#
# 1. Creating a ComponentProcessor
#   A ComponentProcessor needs a block that defines how to process a component. The block
#   will receive the component type and the configuration.
#
#   Example: ComponentProcessor::new do |component_type, configuration|
#              component_type.new(configuration).process
#            end
#
# 2. Registering a component
#   Components need to be registered in the processor. The registration uses an id and a hash
#   of parameters described bellow:
#
#   :type => the type of the component. Only components with a defined type will be passed to the processor block
#   :multiple_instances => a flag to indicate if this component can be added more than once
#   :priority => a number defining a priority for this component to be processed
#   :enabled => a flag to indicate if this component is enabled for processing by default
#   :defaults => a hash containing the default config parameters for this component
#   :send_config => a hash for sending the configurations at process time to another component.
#
#     The configuration keys are sending using the pattern :to_$COMPONENT_ID and supports key overriding
#     Example:
#     :send_config => {
#       :to_bar_service => {
#         :foo => :bar
#       }
#       :to_foo_service => [:foo]
#     }
#     The :foo config will be moved to the component :bar_service using :bar as the configuration key and to the component
#     :foo_service using the same name as the key.
#   :move_config => the same as for :send_config, but the configurations moved will not be passed to the block for this
#   component.
#
# 3. Adding a component
#
# A component should be added by add method. You only need to specify the component id and the configuration (if needed).
# When a component is added, it will be processed for sending or moving configurations and, if the component has a type,
# it will be passed to the block for processing.
#
# author: Marcelo Guimaraes <ataxexe@gmail.com>
class ComponentProcessor

  def initialize &block
    @process = block
  end

  # Register a component using the given id (which must be used for adding it to process) and parameters
  def register component_id, params
    params = {
      :type => nil,
      :multiple_instances => false,
      :priority => 0,
      :enabled => false
    }.merge! params
    @components ||= {}
    params[:configs] ||= [] if params[:multiple_instances]
    params[:defaults] ||= {}
    @components[component_id] = params unless @components.has_key? component_id
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
    enabled_components = @components.find_all {|component_id, params| params[:enabled]}
    (enabled_components.sort_by { |key, value| value[:priority] }).each do |key, component|
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
        @process.call component[:type], config
      end
    else
      config = component[:config]
      config ||= component[:defaults]
      @process.call component[:type], config
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
