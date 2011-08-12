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

    twiddle --datasources --webapps
    twiddle --all

If you don't need to scan for resources, you can specify them for monitoring:

    twiddle --webapps jmx-console,admin-console

Combine with "watch" to get a simple and instantly monitoring:

    watch --interval=1 twiddle --webapps jmx-console,admin-console

Retrieve property values with --get:

    twiddle --get webapp:jmx-console,maxSessions
    twiddle --get server_info,FreeMemory

Set values with --set:

    twiddle --set connector:http-127.0.0.1-8080,maxThreads,350

Execute commands with --invoke:

    twiddle --invoke server,shutdown
    twiddle --invoke web_deployment:jmx-console,stop

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

    - params:

### Configuring deploy folders

Use "deploy_folder" component and the desired folder. If the folder starts with a "/" or
doesn't start with "deploy", the entries in VFS will be added.

    # Will be in $JBOSS_HOME/server/$PROFILE/deploy/application
    - deploy_folder: deploy/applications
    # Will be in $JBOSS_HOME/server/$PROFILE/custom/application
    - deploy_folder: custom/applications
    - deploy_folder: /opt/deploy

### Configuring datasources

### Configuring jmx

Use "jmx" component:

    # user and password are "admin" by default
    - jmx
    - jmx:
        :user: admin
        :password: admin

### Replacing hypersonic

### Installing mod_cluster

### Configuring run.conf

### Slimming

### Configuring jbossweb

### Configuring connectors
