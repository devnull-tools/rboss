rboss
=============

Use this tool to create profiles for JBoss Application Server and use twiddle to scan
a running JBoss AS or execute scripts.


Installation
-----------

    gem install rboss

### Dependencies

    * yummi

### Configuration

Set a RBOSS_CLI_JBOSS_HOME variable pointing to your JBoss AS home location that has jboss-cli
for using rboss-cli, for using twiddle, set a RBOSS_TWIDDLE_HOME variable pointing to you JBoss AS 
that has twiddle.

Using rboss-cli
-----------

rboss-cli is a helper tool for jboss-cli, it maps resource paths and helps the operation
invoke.

### Basics

Invoke the command for a list of mapped resources:

    rboss-cli --help

You can scan resources, detail information and execute operations.

    rboss-cli --datasource
    rboss-cli --server-memory
    rboss-cli --server --operation shutdown

### Invoking Operations

To see the operations for a resource, use the option "--list-operations"

    rboss-cli --server --list-operations

To detail an operation, use the option "--detail-operation"

    rboss-cli --server --detail-operation shutdown

This will print a table showing both request and response parameters. To invoke the
operation, use the "--operation" (or "-o") option

    rboss-cli --server --operation shutdown
    rboss-cli --server -o shutdown

Since this operation requires a parameter, rboss-cli will ask you to input them. If you
want to pass the required parameters, use the "--arguments" (or "-a") option

    rboss-cli --server --operation shutdown --arguments restart=true
    rboss-cli --server -o shutdown -a restart=true

If you want to skip optional arguments, use the "--skip-optional". rboss-cli will not ask
you to input the arguments, leaving "--arguments" as the only way to set them.

### Known Issues

The datasource mapping (--datasource) retrieves incorrect information if you call either
detail operation or invoke operation for the operation add. This is caused because the
command '/subsystem=datasources/data-source=:read-operation-description(name=add)' needs
to be executed as
'/subsystem=datasources/data-source=ANY_VALUE:read-operation-description(name=add)',
leaving the '--datasource any' as a workaround.

    rboss-cli --datasource --detail-operation add
    rboss-cli --datasource a --detail-operation add

### Configuring mappings

To create and override mappings, just put a yaml file in "~/.rboss/rboss-cli/resources". The filename will
be used to identify the operation. Example: placing a file named datasource.yaml will override the
--datasource option and a file named logger.yaml will create a new option (--logger).

The yaml must contain the given definitions:

* description: an explaining text to appear in command usage (--help)
* path: the path to invoke the operations, may take a ${NAME} if the path contains a resource name
* scan (optional): a command to scan resources (by using this, the option may take an array of resource names)
* print (optional): an array of table definitions to print with "read-resource" operation.

To configure a table to print, just use the following parameters:

* id: a name that will be joined to the file name to allow print only this table
* title: the table title
* layout (horizontal | vertical): how the table must be printed. Use vertical for large number of properties
* properties: an array with the properties (returned by "read-resource") to print in this table
* header: an array that maps a header text to the properties
* format: a hash that maps formatters to the table columns
* color: a hash that maps colors to the table columns
* health: a hash that maps health checkers to the table columns

All mappings (formatter, colorizer and health checker) should be mapped using the following conventions:

* the key should be the property name (replace '-' with '_')
* the value should be the message to send to RBoss::Formatters, RBoss::HealthCheckers or RBoss::Colorizers
* if the message takes parameters, they must be specified in a form of a hash after the message

Examples:

    health:
        active:
          percentage:
            max: available
            using: active
    color:
      jndi_name:
        with: purple
      enabled: boolean
      connection_url:
        with: yellow

    format:
      system_load: percentage
    color:
        name:
          with: white
        system_load:
          threshold:
            0.8: intense_red
            0.7: red
            0.5: yellow
            0: green

### Adding new components

To add new Colorizers, Formatters or HealthCheckers, just put the code in the "~/.rboss/rboss.rb".

Example:

    module RBoss::Colorizers
      def self.my_colorizer
        lambda do |value|
          value ? :red : :green
        end
      end
    end

From now you can use this colorizer

    color:
      name: my_colorizer

The components included are defined in the following files:

* /lib/rboss/view/colorizers.rb
* /lib/rboss/view/formatters.rb
* /lib/rboss/view/health_checkers.rb

Using twiddle
-----------

### Basics

Simply do a "cd" to your JBoss Home and use it

    twiddle --help

You can scan resources like: datasources, queues, connectors, webapps, ...

    twiddle --datasource --webapp
    twiddle --all

If you don't need to scan for resources, you can specify them for monitoring:

    twiddle --webapp jmx-console,admin-console

Combine with "watch" to get a simple and instantly monitoring:

    watch --interval=1 twiddle --webapp jmx-console,admin-console

Retrieve property values with --get:

    twiddle --get webapp:jmx-console,maxSessions
    twiddle --get server-info,FreeMemory

Set values with --set:

    twiddle --set connector:http-127.0.0.1-8080,maxThreads,350

Execute commands with --invoke:

    twiddle --invoke server,shutdown
    twiddle --invoke web-deployment:jmx-console,stop

Extending mbeans

You can use a file in ~/.rboss/twiddle.rb for mapping new mbeans or overriding the defaults

    RBoss::Twiddle::Monitor.defaults[:http_request] = {
      :description => 'Request for http protocol',
      :pattern => 'jboss.web:type=GlobalRequestProcessor,name=http-127.0.0.1-8080',
      :properties => %W(requestCount errorCount maxTime)
    }

And use it normally

    twiddle --http-request

You can do every action using custom mbeans

    twiddle --invoke http-request,resetCounters

Configurations can be saved using --save

    twiddle --save jon --port 2099

And used with -c or --config

    twiddle -c jon --server-config

### Customizing MBeans

Every time you run the twiddle command, this gem will load the ~/.rboss/rboss.rb file,
which can be used to customize the mbeans.

    defaults = RBoss::Twiddle::Monitor.defaults
    defaults[:logger] = {
      :description => 'Logger Service',
      :pattern => 'jboss.system:service=Logging,type=Logger'
    }

This will add a custom mbean whose identifier is 'logger'. From that, you can use the
twiddle command on it.

    twiddle --invoke logger debug,message

If your mbean name depends on a resource name (like the connector mbean), you can use
a '#{resource}' string to pass the resource in the command line.

    defaults[:mymbean] => {
      :description => 'My Custom MBean',
      :pattern => 'jboss.custom:type=CustomMBean,name=#{resource}'
    }

Don't forget to use single quotes on that. The twiddle command will be:

    twiddle --get mymbean:Name,MBeanProperty

If this mbean is scannable, you can use a :scan key:

    defaults[:mymbean] => {
      :description => 'My Custom MBean',
      :pattern => 'jboss.custom:type=CustomMBean,name=#{resource}',
      :scan => proc do
        # queries and pass each result do the block
        query "jboss.custom:type=CustomMBean,*" do |path|
          path.gsub "jboss.custom:type=CustomMBean,name=", ""
        end
      end
    }

Now you can scan for resources of your custom MBean by using:

    twiddle --mymbean

If your MBean has some properties that should appear in a table for instant monitoring,
just add a :properties key:

    defaults[:mymbean] => {
      :description => 'My Custom MBean',
      :pattern => 'jboss.custom:type=CustomMBean,name=#{resource}',
      :properties => %W(activeCount currentFree maxAvailable),
      :header => ['Active Count', 'Current Free', 'Max Available'],
      :scan => proc do
        # queries and pass each result do the block
        query "jboss.custom:type=CustomMBean,*" do |path|
          path.gsub "jboss.custom:type=CustomMBean,name=", ""
        end
      end
    }

If this MBean maps a component that can be monitored for health state, you can map the
limits by using a :health key:

    defaults[:mymbean] => {
      :description => 'My Custom MBean',
      :pattern => 'jboss.custom:type=CustomMBean,name=#{resource}',
      :properties => %W(activeCount currentFree maxAvailable),
      :header => ['Active Count', 'Current Free', 'Max Available'],
      :health => {
        :active_count => {
          :percentage => { # uses a percentage based check
            :max => :max_available,
            :using => :active_count #or use :free if you have the number of free resources
          }
        }
      },
      :scan => proc do
        # queries and pass each result do the block
        query "jboss.custom:type=CustomMBean,*" do |path|
          path.gsub "jboss.custom:type=CustomMBean,name=", ""
        end
      end
    }

Customizing health, formatters and colors are the same as customizing in rboss-cli. You can
use the indexes of the values (in that case, 2 for :max and 0 for :using) or the header values
in downcase and underscores.

Using jboss-profile
-----------

### Basics

Simply do a "cd" to your JBoss Home and use it

    jboss-profile --help

All configuration can be stored in a single yaml file containing an array of components
and its configuration:

    - deploy_folder: deploy/datasources
    - deploy_folder: deploy/apps
    - jmx
    - run_conf:
        :heap_size: 1024m
        :perm_size: 512m
        :debug: :socket

You can specify any command-line arguments directly in yaml file:

    - :params:
        :jboss_home: /home/user/jboss/org/jboss-5
        :type: org
        :version: 5.1
        :base_profile: all
        :profile: my_profile

### Configuring deploy folders

Use "deploy_folder" component and the desired folder. If the folder starts with a "/" or
doesn't start with "deploy", the entries in VFS will be added.

    # Will be in $JBOSS_HOME/server/$PROFILE/deploy/application
    - deploy_folder: deploy/applications
    # Will be in $JBOSS_HOME/server/$PROFILE/custom/application
    - deploy_folder: custom/applications
    - deploy_folder: /opt/deploy

### Configuring jmx

Use "jmx" component:

    # user and password are "admin" by default
    - jmx
    - jmx:
        :user: admin
        :password: admin

Basically, this will add an entry in the jmx-console-users.properties (depends on JBoss type).
For JBoss org, this will enable security in jmx-console since the enterprise versions have
jmx-console security by default.

### Configuring datasources

Use a "datasource" component

Configuration:

:folder => a folder where this datasource will be saved (default: $JBOSS_HOME/server/$CONFIG/deploy)
if a relative path is given, it will be appended to default value
:encrypt => a flag to indicate if the password should be encrypted (default: false)
:type => the type of the datasource
:name => a name for saving the file (default: :type)
:attributes => a Hash with the attributes that will be changed in template (the only required is :jndi_name)

Any attribute that is not present in datasource xml will be created using this template: <key>value</key>.

For converting the symbol attributes, the above rules are used taking by example a
value ":database_url":

1. The value "database_url"
2. The value "database-url"
3. The value "DatabaseUrl"
4. The value "DATABASE_URL"

The key for finding the correct datasource is the configuration attribute :type, which is
used to search in $JBOSS_HOME/docs/examples/jca for the file.

Any key that is not found in the datasource template will be added. If it is a Symbol,
the underlines will be converted to hyphens.

For saving the file, the configuration :name will be used in the form "${name}-ds.xml".

Example:

    - datasource:
        :type: postgres
        :attributes:
            :user_name: postgres
            :password: postgres
            :connection_url: jdbc:postgresql://localhost:5432/sample_database
            :min_pool_size: 5
            :max_pool_size: 15

### Replacing hypersonic

The same as Datasouce, but use the "default_ds" component instead.

    - default_ds:
        :type: postgres
        :attributes:
            :user_name: postgres
            :password: postgres
            :connection_url: jdbc:postgresql://localhost:5432/jboss_db
            :min_pool_size: 5
            :max_pool_size: 15

This will change the DefaultDS mapping to the desired datasource. Since JBoss SOA-Platform
already have a tool to do the work, it will be called with the correct mapped options
(see the file $SOAP_HOME/tools/schema/build.properties for the supported options)

    - default_ds:
        source.dir: postgresql84
        db.name: jboss_soap_db
        db.hostname: localhost
        db.port: 5432
        db.username: postgres
        db.password: postgres
        db.minpoolsize: 5
        db.maxpoolsize: 15

### Installing mod_cluster

Use a "mod_cluster" component

Configuration:

:path => where the mod_cluster.sar is located
:folder => where the mod_cluster.sar should be installed (default: $JBOSS_HOME/server/$CONFIG/deploy)

The additional configurations are the entries in the bean ModClusterConfig (mod_cluster-jboss-beans.xml)
and can be in a String form (using the entry name) or in a Symbol form (using ruby nomenclature - :sticky_session)

### Configuring run.conf

### Slimming

Use a "slimming" component.

Configuration:

Use an array with the services to remove, the current supported are:

* Admin Console       => :admin_console
* Web Console         => :web_console
* Mail Service        => :mail
* BeanShell           => :bean_shell
* Hot Deploy          => :hot_deploy
* UDDI                => :uddi
* UUID Key Generator  => :key_generator
* Scheduling          => :scheduling
* JMX Console         => :jmx_console
* JBoss WS            => :jboss_ws
* JMX Remoting        => :jmx_remoting
* ROOT Page           => :root_page
* Management          => :management
* IIOP                => :iiop
* JBoss Web           => :jboss_web
* SNMP                => :snmp
* Profile Service     => :profile
* EJB3                => :ejb3
* EJB2                => :ejb2
* JMX Invoker         => :jmx_invoker
* HA HTTP Invoker     => :ha_http_invoker
* Legacy Invoker      => :legacy_invoker
* Transaction         => :transaction
* Remoting            => :remoting
* Properties Service  => :properties
* Database/Datasource => :database
* JSR-88              => :jsr88
* XNIO                => :xnio

Any slimmed service will be removed logically by using a ".rej" suffix in the files/directories.

Tools
-----------

### Command Line Slimming

You can do a slimming using only the command line, just put your terminal in the profile dir
and do the following:

    jboss-profile --this --slimming services-here

This will slim the defined services. Use --verbose to see the changed files.

To restore slimmed services, use --restore.

    jboss-profile --this --restore services-here

### Password Encryption

You can use the SecureIdentityLoginModule to encrypt a password for use with a login module
to secure a datasource password.

    jboss-profile --encrypt your-password-here

