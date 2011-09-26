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

class JBossWebTest < Test::Unit::TestCase

  def test_http_connector
    for_test_with :all do |profile|
      profile.add :jbossweb,
                  :connectors => {
                    :http => {
                      :max_threads => 600
                    }
                  }
    end

    for_assertions_with :all do |jboss|
      file = "#{jboss.profile}/deploy/jbossweb.sar/server.xml"
      xml = REXML::Document::new File::new(file)
      max_threads = XPath::first xml, "//Connector[@port='8080'][@protocol='HTTP/1.1'][@maxThreads='600']"
      assert max_threads
    end

    do_test
  end

  def test_https_connector
    for_test_with :all do |profile|
      profile.add :jbossweb,
                  :connectors => {
                    :https => {
                      :max_threads => 600
                    }
                  }
    end

    for_assertions_with :all do |jboss|
      file = "#{jboss.profile}/deploy/jbossweb.sar/server.xml"
      xml = REXML::Document::new File::new(file)
      max_threads = XPath::first xml, "//Connector[@port='8443'][@protocol='HTTP/1.1'][@maxThreads='600']"
      assert max_threads
    end

    do_test
  end

  def test_ajp_connector
    for_test_with :all do |profile|
      profile.add :jbossweb,
                  :connectors => {
                    :ajp => {
                      :max_threads => 600
                    }
                  }
    end

    for_assertions_with :all do |jboss|
      file = "#{jboss.profile}/deploy/jbossweb.sar/server.xml"
      xml = REXML::Document::new File::new(file)
      max_threads = XPath::first xml, "//Connector[@port='8009'][@protocol='AJP/1.3'][@maxThreads='600']"
      assert max_threads
    end

    do_test
  end

end
