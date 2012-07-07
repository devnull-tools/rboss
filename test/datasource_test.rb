#                         The MIT License
#
# Copyright (c) 2011-2012 Marcelo Guimarães <ataxexe@gmail.com>
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

class DatasourceTest < Test::Unit::TestCase

  def setup
    @types = %w{mysql oracle postgres}
  end

  def test_datasource_type
    @types.each do |type|
      for_test_with :all do |profile|
        profile.add :datasource,
                    :type => type
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/#{type}-ds.xml"
        assert File.exists? file
        datasource_content = File.read file
        assert datasource_content[type]
      end

      do_test
    end
  end

  def test_datasource_naming
    @types.each do |type|
      for_test_with :all do |profile|
        profile.add :datasource,
                    :type => type,
                    :name => 'my-datasource'
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/my-datasource-ds.xml"
        assert File.exists? file
        datasource_content = File.read file
        assert datasource_content[type]
      end

      do_test
    end
  end

  def test_datasource_folder_inside_installation
    @types.each do |type|
      for_test_with :all do |profile|
        profile.add :deploy_folder, 'deploy/datasources'

        profile.add :datasource,
                    :type => type,
                    :folder => 'deploy/datasources'
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/datasources/#{type}-ds.xml"
        assert File.exists? file
        datasource_content = File.read file
        assert datasource_content[type]
      end

      do_test
    end
  end

  def test_datasource_folder_outside_installation
    @types.each do |type|
      for_test_with :all do |profile|
        profile.add :deploy_folder, '/tmp/datasources'

        profile.add :datasource,
                    :type => type,
                    :folder => '/tmp/datasources'
      end

      for_assertions_with :all do |jboss|
        file = "/tmp/datasources/#{type}-ds.xml"
        assert File.exists? file
        datasource_content = File.read file
        assert datasource_content[type]

        `rm -rf /tmp/datasources`
      end

      do_test
    end
  end

  def test_datasource_attributes
    @types.each do |type|
      for_test_with :all do |profile|

        profile.add :datasource,
                    :type => type,
                    :attributes => {
                      :jndi_name => "#{type}Datasource",
                      :user_name => "#{type}_user",
                      :password => "#{type}_password",
                      :connection_url => "#{type}_connection",
                      :driver_class => "#{type}_class"
                    }
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/#{type}-ds.xml"
        xml = REXML::Document::new File::new(file)

        assert_tag xml, "//jndi-name", "#{type}Datasource", "local-tx-datasource"
        assert_tag xml, "//user-name", "#{type}_user", "local-tx-datasource"
        assert_tag xml, "//password", "#{type}_password", "local-tx-datasource"
        assert_tag xml, "//connection-url", "#{type}_connection", "local-tx-datasource"
        assert_tag xml, "//driver-class", "#{type}_class", "local-tx-datasource"
      end

      do_test
    end
  end

  def test_new_datasource_attributes
    @types.each do |type|
      for_test_with :all do |profile|

        profile.add :datasource,
                    :type => type,
                    :attributes => {
                      :min_pool_size => 10,
                      :max_pool_size => 50,
                      :use_java_context => true
                    }
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/#{type}-ds.xml"
        xml = REXML::Document::new File::new(file)

        assert_tag xml, "//min-pool-size", 10, "local-tx-datasource"
        assert_tag xml, "//max-pool-size", 50, "local-tx-datasource"
      end

      do_test
    end
  end

  def test_datasource_encryption
    @types.each do |type|
      for_test_with :all do |profile|

        profile.add :datasource,
                    :type => type,
                    :encrypt => true,
                    :attributes => {
                      :jndi_name => "MyDatasource",
                      :user_name => "user-name",
                      :password => "password"
                    }
      end

      for_assertions_with :all do |jboss|
        file = "#{jboss.profile}/deploy/#{type}-ds.xml"
        xml = REXML::Document::new File::new(file)

        assert XPath::first(xml, "//user-name").nil?
        assert XPath::first(xml, "//password").nil?

        assert_tag xml, "//security-domain", type, "local-tx-datasource"

        xml = REXML::Document::new File::new("#{jboss.profile}/deploy/#{type}.login-module.xml")

        application_policy = XPath::first xml, "//application-policy[@name='#{type}']"
        assert !application_policy.nil?
        assert application_policy.parent.name == "policy"

        assert_tag application_policy, ".//module-option[@name='username']", "user-name", "login-module"
        assert_tag application_policy, ".//module-option[@name='password']", "5dfc52b51bd35553df8592078de921bc", "login-module"
        assert_tag application_policy, ".//module-option[@name='managedConnectionFactoryName']", "jboss.jca:name=MyDatasource,service=LocalTxCM", "login-module"
      end

      do_test
    end
  end

  def assert_tag xml, path, value, parent_name = nil
    tag = XPath::first xml, path
    assert tag.text.strip == value.to_s
    assert tag.parent.name == parent_name if parent_name
  end

end
