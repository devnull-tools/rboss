require_relative "command_invoker"
require_relative "jboss"

require "logger"

# A class to add resources to a JBoss Profile
#
# Any resource can be added using the following structure:
#
# absolute_path => [resource_a_path, resource_b_path, ...],
# relative_path => resource_c_path
#
# Relative paths are based on the profile path (example: "lib" is $JBOSS_HOME/server/$JBOSS_PROFILE/lib)
#
# author: Marcelo Guimaraes <ataxexe@gmail.com>
class JBossResource
  include CommandInvoker

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
        to_path = "#{@jboss.profile}/#{to_path}" unless to_path.start_with? '/'
        invoke "cp #{resource} #{to_path}"
      end
    end
  end

end
