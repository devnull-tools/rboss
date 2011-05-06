require 'test/unit'
require_relative 'test_helper'

class DeployFolderTest < Test::Unit::TestCase

  def test_folder_inside_deploy
    for_test do |profile|
      profile.add :deploy_folder, 'deploy/rboss-deploy'
      profile.add :deploy_folder, 'deploy/rboss/deploy'

      for_assertions do
        assert(File.exists? "#{@jboss.profile}/deploy/rboss-deploy")
        assert(File.exists? "#{@jboss.profile}/deploy/rboss/deploy")
      end
    end

    do_test_with :org, "5.1.0.GA"
    do_test_with :org, "6.0.0.Final"
    do_test_with :eap, "5.1"
    do_test_with :eap, "5.0"
    do_test_with :soa_p, 5
    do_test_with :soa_p, "5.0.0"
  end

  def test_folder_outside_deploy
    for_test do |profile|
      profile.add :deploy_folder, 'rboss-deploy'
      profile.add :deploy_folder, 'rboss/deploy'

      for_assertions do
        assert(File.exists? "#{@jboss.profile}/rboss-deploy")
        assert(File.exists? "#{@jboss.profile}/rboss/deploy")
      end
    end

    do_test_with :org, "5.1.0.GA"
    do_test_with :org, "6.0.0.Final"
    do_test_with :eap, "5.1"
    do_test_with :eap, "5.0"
    do_test_with :soa_p, 5
    do_test_with :soa_p, "5.0.0"
  end

  def test_folder_outside_jboss
    for_test do |profile|
      profile.add :deploy_folder, '/tmp/rboss-deploy'
      profile.add :deploy_folder, '/tmp/rboss/deploy'

      for_assertions do
        assert(File.exists? "#{@jboss.profile}/rboss-deploy")
        assert(File.exists? "#{@jboss.profile}/rboss/deploy")
      end
    end

    do_test_with :org, "5.1.0.GA"
    do_test_with :org, "6.0.0.Final"
    do_test_with :eap, "5.1"
    do_test_with :eap, "5.0"
    do_test_with :soa_p, 5
    do_test_with :soa_p, "5.0.0"

    `rm -rf /tmp/rboss*`
  end

end
