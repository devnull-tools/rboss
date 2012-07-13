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

module RBoss

  # An extension to the base JXM class that secures the jmx-console
  # for the JBoss.org servers.
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class JMX

    alias_method :base_process, :process

    def process
      base_process
      secure_jmx_console
    end

    def secure_jmx_console
      processor = new_file_processor
      processor.with "#{@jboss.profile}/deploy/jmx-console.war/WEB-INF/jboss-web.xml", :xml do |action|
        action.to_process do |xml, jboss|
          xml.root << Document::new("<security-domain>java:/jaas/jmx-console</security-domain>")
          xml
        end
      end
      processor.with "#{@jboss.profile}/deploy/jmx-console.war/WEB-INF/web.xml" do |action|
        action.to_process do |content, jboss|
          content.gsub! /<security-constraint>/, "--> <security-constraint>"
          content.gsub! /<\/security-constraint>/, "</security-constraint><!--"
          content
        end
      end
      processor.process
    end

  end

end

