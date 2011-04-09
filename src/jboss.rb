require_relative "file_path_builder"

require "ostruct"
require "logger"

# A class that represents the JBoss structure.
# 
# author Marcelo Guimaraes <ataxexe@gmail.com>
class JBoss < FilePathBuilder

  attr_reader :instance, :instance_name, :home

  def initialize jboss_home, instance_name = :custom
    super jboss_home
    @home = FilePathBuilder::new jboss_home
    @instance = FilePathBuilder::new "#{jboss_home}/server/#{instance_name}"
    @instance_name = instance_name.to_s
  end

end

