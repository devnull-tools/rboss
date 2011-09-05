rboss
=============

Use this tool to create profiles for JBoss Application Server and use twiddle to scan
a running JBoss AS or execute scripts.


Installation
-----------

    gem install rboss

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

    JBoss::Twiddle::Monitor.defaults[:http_request] = {
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
* Bsh Deployer        => :bsh_deployer
* Hot Deploy          => :hot_deploy
* JUDDI               => :juddi
* UUID Key Generator  => :key_generator
* Scheduling          => :scheduling
* JMX Console         => :jmx_console
* JBoss WS            => :jboss_ws
* JMX Remoting        => :jmx_remoting
* ROOT Page           => :root_page

Any slimmed service will be removed logically by using a ".rej" suffix in the files/directories.

### Configuring jbossweb

### Configuring connectors
