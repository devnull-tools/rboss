#                         The MIT License
#
# Copyright (c) 2011 Marcelo Guimarães <ataxexe@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative 'test_helper'

class DeployFolderTest < Test::Unit::TestCase

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

      check_profile_xml "${jboss.server.home.url}rboss-deploy", "${jboss.server.home.url}rboss/deploy"
      check_vfs_xml "${jboss.server.home.url}rboss-deploy", "${jboss.server.home.url}rboss/deploy" unless jboss.version == 6.0
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

      check_profile_xml 'file:///tmp/rboss-deploy', 'file:///tmp/rboss/deploy'
      check_vfs_xml 'file:///tmp/rboss-deploy', 'file:///tmp/rboss/deploy' unless jboss.version == 6.0
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
