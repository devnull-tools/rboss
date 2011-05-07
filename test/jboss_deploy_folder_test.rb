require_relative 'test_helper'

class DeployFolderTest < Test::Unit::TestCase

  def setup
    @all= {
      :org => "5.1.0.GA",
      :eap => ["5.0", "5.1"],
      :soa_p => ["5", "5.0.0"]
    }
  end

  def test_folder_inside_deploy
    for_test_with :all do |profile|
      profile.add :deploy_folder, 'deploy/rboss-deploy'
      profile.add :deploy_folder, 'deploy/rboss/deploy'
    end

    for_assertions_with :all do |jboss|
      assert(File.exists? "#{jboss.profile}/deploy/rboss-deploy")
      assert(File.directory? "#{jboss.profile}/deploy/rboss-deploy")
      assert(File.exists? "#{jboss.profile}/deploy/rboss/deploy")
      assert(File.directory? "#{jboss.profile}/deploy/rboss/deploy")
    end

    do_test
  end

  def test_folder_outside_deploy
    for_test_with :all do |profile|
      profile.add :deploy_folder, 'rboss-deploy'
      profile.add :deploy_folder, 'rboss/deploy'
    end

    for_assertions_with :all do |jboss|
      assert(File.exists? "#{jboss.profile}/rboss-deploy")
      assert(File.directory? "#{jboss.profile}/rboss-deploy")
      assert(File.exists? "#{jboss.profile}/rboss/deploy")
      assert(File.directory? "#{jboss.profile}/rboss/deploy")

      #TODO check vfs.xml
      check_profile_xml "${jboss.server.home.url}rboss-deploy", "${jboss.server.home.url}rboss/deploy"
      check_vfs_xml "${jboss.server.home.url}rboss-deploy", "${jboss.server.home.url}rboss/deploy"
    end

    do_test
  end

  def test_folder_outside_jboss
    for_test_with :all do |profile|
      profile.add :deploy_folder, '/tmp/rboss-deploy'
      profile.add :deploy_folder, '/tmp/rboss/deploy'
    end

    for_assertions_with :all do |jboss|
      assert(File.exists? "/tmp/rboss-deploy")
      assert(File.directory? "/tmp/rboss-deploy")
      assert(File.exists? "/tmp/rboss/deploy")
      assert(File.directory? "/tmp/rboss/deploy")

      #TODO check vfs.xml
      check_profile_xml 'file:///tmp/rboss-deploy', 'file:///tmp/rboss/deploy'
      check_vfs_xml 'file:///tmp/rboss-deploy', 'file:///tmp/rboss/deploy'
    end

    do_test

    `rm -rf /tmp/rboss*`
  end

  def check_profile_xml *names
    xml = REXML::Document::new File::new("#{@jboss.profile}/conf/bootstrap/profile.xml")
    element = XPath.first xml, "//property[@name='applicationURIs']"
    element = XPath.first element, "//list[@elementClass='java.net.URI']"
    element.each do |el|
      names.delete el.text.strip if el.respond_to? :text
    end
    assert(names.empty?)
  end

  def check_vfs_xml *names
    xml = REXML::Document::new File::new("#{@jboss.profile}/conf/bootstrap/vfs.xml")
    element = XPath.first xml, "//property[@name='permanentRoots']"
    element = XPath.first element, "//map[@keyClass='java.net.URL']"
    XPath.each element, "//key" do |el|
      if el.respond_to? :text
        names.delete el.text.strip
        value = XPath.first el.parent, "//value"
        inject = XPath.first value, "//inject"
        assert(inject.attributes["bean"] == "VfsNamesExceptionHandler")
      end
    end
    assert(names.empty?)
  end

end
