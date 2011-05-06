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

        #TODO check vfs.xml
        check_profile_xml "${jboss.server.home.url}rboss-deploy", "${jboss.server.home.url}rboss/deploy"
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

        #TODO check vfs.xml
        check_profile_xml 'file:///tmp/rboss-deploy', 'file:///tmp/rboss/deploy'
      end
    end

    do_test_with_all

    `rm -rf /tmp/rboss*`
  end

  def check_profile_xml *names
    xml = REXML::Document::new File::new("#{@jboss.profile}/conf/bootstrap/profile.xml")

    element = XPath.first xml, "//property[@name='applicationURIs']"
    element = XPath.first element, "//list[@elementClass='java.net.URI']"
    element.each do |el|
      names.delete el.text.strip if el.respond_to? :text
    end
    assert(names.empty?, "#{@jboss.profile}/conf/bootstrap/profile.xml does not contains #{names}")
  end

  def check_vfs_xml *names

  end

end
