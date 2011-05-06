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

require_relative "jboss_datasource"
require_relative "jboss_component"

require "logger"
require "rexml/document"

include REXML

module JBoss

  # A class to configure a JBoss XADatasource.
  #
  # The configuration will change a <xa-datasource-property> value.
  #
  # Configuration attributes are the same as for a JBoss::Datasource
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class XADatasource < Datasource
    include Component

    def initialize jboss, logger, config
      super jboss, logger, config
      @type << "-xa"
    end

    def configure_datasource xml
      if @encrypt
        xml.delete_element "//xa-datasource-property[@name='User']"
        xml.delete_element "//xa-datasource-property[@name='Password']"
        @service = "XATxCM"
      end
      @attributes.each do |key, value|
        element = find(xml, key) {|k| "//xa-datasource-property[@name='#{k}']"}

        if element
          element.text = value
        else
          insert_attribute xml, key, value
        end
      end
    end

  end

end
