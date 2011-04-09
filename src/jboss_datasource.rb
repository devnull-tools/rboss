require_relative "file_processor"
require_relative "jboss"
require_relative "command_invoker"
require_relative "file_path_builder"
require_relative "utils"

require "logger"
require "rexml/document"

include REXML

# A class to configure a JBoss Datasource.
# 
# The configuration will be dynamic converted using the following conventions:
# 1- For a XA Datasource
#   The class will change a <xa-datasource-property> value
# 2- For a normal Datasource
#   The class will change a <$property> value
#
# PS: For both, the jndi replacement is the same (<jndi-name>).
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
# author: Marcelo Guimaraes <ataxexe@gmail.com>
class JBossDatasource
  include FileProcessorBuilder, CommandInvoker

  attr_reader :attributes, :type, :name
  attr_accessor :jndi_name

  def initialize jboss, logger, config
    config = {
      :folder => jboss.instance.deploy,
      :encrypt => false,
      :attributes => {}
    }.merge! config
    @jboss = jboss
    @logger = logger
    @type = config[:type].to_s.gsub /_/, '-'
    @name = config[:name]
    @name ||= @type.to_s
    @folder = config[:folder].to_s
    @folder = @jboss.instance.deploy @folder unless @folder.start_with? '/'
    @attributes = config[:attributes]
    @encrypt = config[:encrypt]
    @jndi_name = @attributes.delete :jndi_name
  end

  def process
    processor = create_file_processor
    processor.with @jboss.docs.examples.jca("#{@type}-ds.xml"), :xml do |action|
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
    create_login_module if @encrypt
    update_login_config if @encrypt
  end

  def find xml, key
    if key.is_a? Symbol
      key = key.to_s
      [key, key.gsub(/_/, '-'), key.to_jboss_property, key.upcase].each do |k|
        element = XPath.first xml, yield(k)
        return element if element
      end
    else
      XPath.first xml, yield(k)
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
      element = find(xml, key) {|k| "//#{k}"}

      if element
        element.text = value
      else
        insert_attribute xml, key, value
      end
    end
  end

  #TODO create a :xa_datasource component for this
  def configure_xa_datasource xml
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

  def insert_attribute xml, key, value
    if key.is_a? Symbol
      element = Element::new key.to_s.gsub /_/, '-'
    else
      element = Element::new key
    end
    element.text = value
    xml.root.elements[1] << element
  end

  def update_login_config
    processor = create_file_processor
    processor.with @jboss.instance.conf('login-config.xml'), :xml do |action|
      action.to_process do |xml, jboss|
        xml.root << @login_module
        xml
      end
    end
    processor.process
  end

  def create_login_module
    user = @attributes.delete :user
    user = @attributes.delete :user_name unless user
    password = encrypt @attributes.delete :password

    @login_module = Document::new <<XML
<application-policy name='#{@name}'>
  <authentication>
    <login-module code='org.jboss.resource.security.SecureIdentityLoginModule' flag='required'>
      <module-option name='username'>
        #{user}
      </module-option>
      <module-option name='password'>
        #{password}
      </module-option>
      <module-option name='managedConnectionFactoryName'>
        jboss.jca:name=#{@jndi_name},service=#{@service}
      </module-option>
    </login-module>
  </authentication>
</application-policy>
XML
  end

  # Encrypts the given password using the SecureIdentityLoginModule
  # TODO make it compatible with JBoss EAP 5.0 (works only in JBoss EAP 5.1)
  def encrypt password
    encrypted = invoke "java -cp #{@jboss.home}/client/jboss-logging-spi.jar:#{@jboss.home}/lib/jbosssx.jar org.jboss.resource.security.SecureIdentityLoginModule #{password}"
    encrypted.chomp.split(/:/)[1].strip
  end

end
