require 'test/unit'
require_relative 'test_helper'

class DeployFolderTest < Test::Unit::TestCase

  def test_folder_inside_deploy
    for_test do |jboss, profile|
      profile.add :deploy_folder, 'deploy/rboss-deploy'
      profile.add :deploy_folder, 'deploy/rboss/deploy'

      for_assertions do
        assert(File.exists? "#{jboss.profile}/deploy/rboss-deploy")
        assert(File.directory? "#{jboss.profile}/deploy/rboss-deploy")
        assert(File.exists? "#{jboss.profile}/deploy/rboss/deploy")
        assert(File.directory? "#{jboss.profile}/deploy/rboss/deploy")
      end
    end

    do_test_with_all
  end

  def test_folder_outside_deploy
    for_test do |jboss, profile|
      profile.add :deploy_folder, 'rboss-deploy'
      profile.add :deploy_folder, 'rboss/deploy'

      for_assertions do
        assert(File.exists? "#{jboss.profile}/rboss-deploy")
        assert(File.directory? "#{jboss.profile}/rboss-deploy")
        assert(File.exists? "#{jboss.profile}/rboss/deploy")
        assert(File.directory? "#{jboss.profile}/rboss/deploy")

        #todo check profile.xml and vfs.xml
      end
    end

    do_test_with_all
  end

  def test_folder_outside_jboss
    for_test do |jboss, profile|
      profile.add :deploy_folder, '/tmp/rboss-deploy'
      profile.add :deploy_folder, '/tmp/rboss/deploy'

      for_assertions do
        assert(File.exists? "/tmp/rboss-deploy")
        assert(File.directory? "/tmp/rboss-deploy")
        assert(File.exists? "/tmp/rboss/deploy")
        assert(File.directory? "/tmp/rboss/deploy")

        #todo check profile.xml and vfs.xml
      end
    end

    do_test_with_all

    `rm -rf /tmp/rboss*`
  end

end
