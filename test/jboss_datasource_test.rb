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

class DatasourceTest < Test::Unit::TestCase

  def setup
    @types = %w{mysql oracle postgres hsqldb firebird}
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

end
