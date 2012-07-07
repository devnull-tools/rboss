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

# A main class to process components based on a highly customizable set of parameters.
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
#
#   :multiple_instances => a flag to indicate if this component can be added more than once
#   :priority => a number defining a priority for this component to be processed
#
#   :enabled => a flag to indicate if this component is enabled for processing by default
#
#   :defaults => a hash containing the default config parameters for this component (only if the configuration is a Hash)
#
#   :send_config => a hash for sending the configurations at process time to another component (only if the configuration
#   is a Hash).
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
#
#   :move_config => the same as for :send_config, but the configurations moved will not be passed to the block for this
#   component.
#
# 3. Adding a component
#
# A component should be added by add method. You only need to specify the component id and the configuration (if needed).
# When a component is added, it will be processed for sending or moving configurations and, if the component has a type,
# it will be passed to the block for processing.
#
# author: Marcelo Guimarães <ataxexe@gmail.com>
class ComponentProcessor

  def initialize &block
    @process = block
    @process ||= lambda { |type, config| type.new(config).process }
  end

  # Register a component using the given id (which must be used for adding it to process) and parameters
  def register component_id, params
    params = {
      :type => nil,
      :multiple_instances => false,
      :priority => 0,
      :enabled => false,
      :defaults => {}
    }.merge! params
    @components ||= {}
    params[:configs] ||= [] if params[:multiple_instances]
    @components[component_id] = params unless @components.has_key? component_id
  end

  def add component_id, config = {}
    registered_component = @components[component_id]
    return unless registered_component
    defaults = registered_component[:defaults]
    registered_component[:enabled] = true
    config = defaults.merge config if config.is_a? Hash
    if registered_component[:multiple_instances]
      registered_component[:configs] << config
    else
      registered_component[:config] = config
    end
    propagate_configs registered_component
  end

  def defaults component_id, defaults
    registered_component = @components[component_id]
    registered_component[:defaults] = defaults if registered_component
  end

  def process_components
    enabled_components = @components.find_all {|component_id, params| params[:enabled]}
    (enabled_components.sort_by { |key, value| value[:priority] }).each do |key, component|
      process_component component
    end
  end

  private

  def process_component component
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

  def propagate_configs component
    #TODO refactor this -----------------------------------
    if component[:send_config] and component[:config].is_a? Hash
      component[:send_config].each do |to, keys|
        destination = to.to_s.gsub(/^to_/, '').to_sym
        config = {}
        if keys.is_a? Array
          keys.each do |key|
            config[key] = component[:config][key] if component[:config].has_key? key
          end
        elsif keys.is_a? Hash
          keys.each do |k, v|
            config[v] = component[:config][k] if component[:config].has_key? k
          end
        end
        send_config destination, config
      end
    end
    if component[:move_config] and component[:config].is_a? Hash
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
        send_config destination, config, :enable_component => true
      end
    end
    #------------------------------------------------------
  end

  def send_config component_id, config, opts = {}
    component = @components[component_id]
    component[:defaults] ||= {}
    component_config = @components[component_id][:defaults]
    component_config.merge! config
    component[:enabled] = true if opts[:enable_component]
  end

end
