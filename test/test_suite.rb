require 'test/unit'
require 'test/unit/testsuite'
require_relative 'jboss_deploy_folder_test'

class TestSuite < Test::Unit::TestSuite

  def initialize
    self << DeployFolderTest
  end

end
