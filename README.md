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

All configuration can be stored in a single yaml file:

    - deploy_folder: deploy/datasources
    - deploy_folder: deploy/apps
    - jmx
    - run_conf:
        :heap_size: 1024m
        :perm_size: 512m
        :debug: :socket

### Configuring deploy folders

### Configuring datasources

### Configuring jmx

### Replacing hypersonic

### Installing mod_cluster

### Configuring run.conf

### Slimming

### Configuring jbossweb

### Configuring connectors
