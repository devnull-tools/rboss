require_relative "file_processor"
require_relative "command_invoker"
require_relative "jboss"
require_relative "utils"

require "logger"

# author: Marcelo Guimaraes <ataxexe@gmail.com>
class JBossResource
  include FileProcessorBuilder, CommandInvoker

  def initialize jboss, logger, resources
    @jboss = jboss
    @logger = logger
    @resources = resources
  end

  def process
    @logger.info "Including resources..." unless @resources.empty?
    @resources.each do |to_path, resources|
      resources = [resources] unless resources.is_a? Array
      resources.each do |resource|
        to_path = "#{@jboss.instance}/#{to_path}" unless to_path.start_with? '/'
        invoke "cp #{resource} #{to_path}"
      end
    end
  end

end
