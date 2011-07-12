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

require_relative 'component'

require "rexml/document"

include REXML

module JBoss
  class Web
    include Component

    def defaults
      {
        :connectors => [],
        :jvm_route => nil
      }
    end

    def connector_defaults
      {
        :http => {
          :address => "${jboss.bind.address}",
          :protocol => "HTTP/1.1",
          :port => 8080
        },
        :ajp => {
          :address => "${jboss.bind.address}",
          :protocol => "AJP/1.3",
          :port => 8009,
          :redirect_port => 8443
        },
        :https => {
          :addres => "${jboss.bind.address}",
          :port => 8443,
          :scheme => "https",
          :secure => true,
          :ssl_protocol => "TLS",
          :client_auth => false,
          :keystore_file => '${jboss.server.home.dir}/conf/.keystore'
        },
        :other => {
          :address => "${jboss.bind.address}",
          :protocol => "HTTP/1.1"
        }
      }
    end

    def process
      @processor = new_file_processor
      @actions = []
      configure_connectors
      configure_engine
      @processor.with "#{@jboss.profile}/deploy/jbossweb.sar/server.xml", :xml do |action|
        action.to_process do |xml, jboss|
          @actions.each do |block|
            xml = block.call(xml, jboss)
          end
          xml
        end
      end
      @processor.process
    end

    def configure_connectors
      @config[:connectors].each do |type, attributes|
        defaults = connector_defaults[type.to_sym]
        defaults ||= connector_defaults[:other]
        attributes = defaults.merge attributes
        configure_connector attributes, defaults
      end
    end

    def configure_connector attributes, defaults
      @actions << lambda do |xml, jboss|
        tag = XPath.first xml, "//Connector[@protocol='#{defaults[:protocol]}'][@port='#{defaults[:port]}']"
        unless tag
          tag = Element::new "Connector"
          xml.insert_after "//Connector", tag
        end
        attributes.each do |key, value|
          key = key.to_s.camelize.uncapitalize if key.is_a? Symbol
          tag.attributes[key] = value.to_s
        end
        puts tag
        xml
      end
    end

    def configure_engine
      @actions << lambda do |xml, jboss|
        engine = XPath.first xml, "//Engine[@name='jboss.web']"
        route = ":#{@config[:jvm_route]}" if @config[:jvm_route]
        route ||= ''
        engine.attributes["jvmRoute"] = "${jboss.jbossweb.jvmRoute#{route}}"
        xml
      end
    end
  end
end
