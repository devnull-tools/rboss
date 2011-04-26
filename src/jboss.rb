require_relative "file_path_builder"

require "ostruct"
require "logger"

# A class that represents the JBoss structure.
# 
# author Marcelo Guimaraes <ataxexe@gmail.com>
class JBoss < FilePathBuilder

  attr_reader :profile, :profile_name, :home

  def initialize jboss_home, profile = :custom
    super jboss_home
    @home = FilePathBuilder::new jboss_home
    @profile = FilePathBuilder::new "#{jboss_home}/server/#{profile}"
    @profile_name = profile.to_s
  end

end

