require 'test/unit'
require_relative 'test_helper'

class DeployFolderTest < Test::Unit::TestCase

  def test_folder_inside_deploy
    create_eap do |jboss|
      jboss.add :deploy_folder, 'rboss-deploy'
      jboss.add :deploy_folder, 'rboss/deploy'
    end

    assertions do
      assert(File.exists? "#{@jboss.profile}/deploy/rboss-deploy")
      assert(File.exists? "#{@jboss.profile}/deploy/rboss/deploy")
    end
  end

end
