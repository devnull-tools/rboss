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

require_relative "component"

require "logger"
require "rexml/document"

include REXML

module JBoss

  # A class to configure a JBoss Datasource.
  #
  # For converting the property (if it is a Symbol), the above rules are used taking by example a
  # value ":database_url":
  #   a. The value "database_url"
  #   b. The value "database-url"
  #   c. The value "DatabaseUrl"
  #   d. The value "DATABASE_URL"
  #
  # The key for finding the correct datasource is the configuration attribute :type, which is used
  # to search in $JBOSS_HOME/docs/examples/jca for the file.
  #
  # Any key that is not found in the datasource template will be added. If it is a Symbol, the underlines will be
  # converted to hyphens.
  #
  # For saving the file, the configuration :name will be used in the form "${name}-ds.xml".
  #
  # Configuration:
  #
  # :folder => a folder where this datasource will be saved (default: $JBOSS_HOME/server/$CONFIG/deploy)
  #            if a relative path is given, it will be appended to default value
  # :encrypt => a flag to indicate if the password should be encrypted (default: false)
  # :type => the type of the datasource
  # :name => a name for saving the file (default: :type)
  # :attributes => a Hash with the attributes that will be changed in template (the only required is :jndi_name)
  #   Any attribute that is not present in datasource xml will be created using this template: <key>value</key>.
  #
  # author: Marcelo Guimarães <ataxexe@gmail.com>
  class Datasource
    include Component

    attr_accessor :jndi_name, :attributes, :type, :name

    def defaults
      {
        :folder => "#{@jboss.profile}/deploy",
        :encrypt => false,
        :attributes => {}
      }
    end

    def configure config
      @type = config[:type].to_s.gsub /_/, '-'
      @name = config[:name]
      @name ||= @type.to_s
      @folder = config[:folder].to_s
      @folder = "#{@jboss.profile}/#{@folder}" unless @folder.start_with? '/'
      @attributes = config[:attributes]
      @encrypt = config[:encrypt]
      @jndi_name = @attributes.delete :jndi_name
    end

    def process
      if @encrypt
        @user = @attributes.delete :user
        @user = @attributes.delete :user_name unless @user
        @password = encrypt @attributes.delete :password
      end
      processor = new_file_processor
      processor.with "#{@jboss.home}/docs/examples/jca/#{@type}-ds.xml", :xml do |action|
        action.to_process do |xml, jboss|
          element = XPath.first xml, "//jndi-name"
          element.text = @jndi_name
          configure_datasource xml

          if @encrypt
            security_domain = Element::new "security-domain"
            security_domain.text = @name

            xml.root.elements[1] << security_domain
          end
          action.copy_to "#{@folder}/#{@name}-ds.xml"
          xml
        end
      end
      @logger.info "Creating datasource #{@name}"
      processor.process
      if @encrypt
        create_login_module
        create_login_config
      end
    end

    def find xml, key
      if key.is_a? Symbol
        key = key.to_s
        [key, key.gsub(/_/, '-'), key.camelize, key.upcase].each do |k|
          element = XPath.first xml, yield(k)
          return element if element
        end
      else
        XPath.first xml, yield(key)
      end
      nil
    end

    def configure_datasource xml
      if @encrypt
        xml.root.delete_element "//user-name"
        xml.root.delete_element "//password"
        @service = "LocalTxCM"
      end
      @attributes.each do |key, value|
        element = find(xml, key) { |k| "//#{k}" }

        if element
          element.text = value
        else
          insert_attribute xml, key, value
        end
      end
    end

    def insert_attribute xml, key, value
      if key.is_a? Symbol
        element = Element::new key.to_s.gsub /_/, '-'
      else
        element = Element::new key
      end
      element.text = value
      xml.root.elements[1] << element
    end

    def create_login_config
      File.open("#{@folder}/#{@name}.login-module.xml", 'w+') { |f| f.write @login_module }
    end

    def create_login_module
      @login_module = Document::new <<XML
<policy>
  <application-policy name='#{@name}'>
    <authentication>
      <login-module code='org.jboss.resource.security.SecureIdentityLoginModule' flag='required'>
        <module-option name='username'>#{@user}</module-option>
        <module-option name='password'>#{@password}</module-option>
        <module-option name='managedConnectionFactoryName'>jboss.jca:name=#{@jndi_name},service=#{@service}</module-option>
      </login-module>
    </authentication>
  </application-policy>
</policy>
XML
    end

    def jboss_logging_lib_path
      %W{#{@jboss.home}/client/jboss-logging-spi.jar #{@jboss.home}/client/jboss-logging.jar}.each do |path|
        return path if File.exist? path
      end
    end

    def jbosssx_lib_path
      %W{#{@jboss.home}/lib/jbosssx.jar #{@jboss.home}/common/lib/jbosssx.jar}.each do |path|
        return path if File.exist? path
      end
    end

    # Encrypts the given password using the SecureIdentityLoginModule
    def encrypt password
      cmd = "java -cp #{jboss_logging_lib_path}:#{jbosssx_lib_path} org.jboss.resource.security.SecureIdentityLoginModule #{password}"
      encrypted = `#{cmd}`
      encrypted.chomp.split(/:/)[1].strip
    end

  end

end
