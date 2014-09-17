rboss
=============

This tool helps you manage a JBoss application server (EAP or Wildfly) by encapsulating `jboss-cli` in a usefull and customizable command line tool.

Installation
-----------

    gem install rboss

### Configuration

Set a `RBOSS_CLI_HOME` variable pointing to your JBoss AS home location that has `jboss-cli` for using `rboss-cli`.

Using rboss-cli
-----------

`rboss-cli` is a helper tool for `jboss-cli`, it maps resource paths and helps the operation invoke.

### Basics

Invoke the command for a list of mapped resources:

    rboss-cli --help

You can scan resources, detail information and execute operations.

    rboss-cli --datasource
    rboss-cli --server-memory
    rboss-cli --server --operation shutdown

### Invoking Operations

To see the operations for a resource, use the `--list-operations` or `-l` option:

    rboss-cli --server --list-operations

To detail an operation, use the `--detail-operation` or `-d` option:

    rboss-cli --server --detail-operation shutdown

This will print a table showing both request and response parameters. To invoke the operation, use the `--operation` or `-o` option:

    rboss-cli --server --operation shutdown
    rboss-cli --server -o shutdown

Since this operation requires a parameter, rboss-cli will ask you to input them. If you want to pass the required parameters, use the `--arguments` or `-a` option:

    rboss-cli --server --operation shutdown --arguments restart=true
    rboss-cli --server -o shutdown -a restart=true
    
Multiple arguments are supported using commas:

    rboss-cli --some-resource -o operation -a arg1=value1,arg2=value

If you want to skip optional arguments, use the `--skip-optional`. `rboss-cli` will not ask you to input optional arguments, leaving `--arguments` as the only way to set them.

See `rboss-cli --help` for a complete list of commands.

### Bash Completion

You can also source the `rboss-cli-bash-completion` file to make use of the completion for the `rboss-cli`. The completion works for parameters, resource arguments and operations.

    $ rboss-cli --dat[TAB]
    $ rboss-cli --datasource Exa[TAB]
    $ rboss-cli --datasource ExampleDS

Keep in mind that if you need completion for a different server than `local` (the default server), you should start the command with `--connect` or `-c`:

    $ rboss-cli --connect my[TAB]
    $ rboss-cli --connect myserver
    $ rboss-cli --connect myserver --dat[TAB]
    $ rboss-cli --connect myserver --datasource Exa[TAB]
    $ rboss-cli --connect myserver --datasource ExampleDS

### Configuring CLI mappings

To create and override mappings, just put a yaml file in `~/.rboss/rboss-cli/resources`. The filename will be used to identify the operation. Example: placing a file named datasource.yaml will override the `--datasource` option and a file named `logger.yaml` will create a new option (`--logger`). The yaml must contain the given definitions:

* description: an explaining text to appear in command usage (`--help`)
* path: the path to invoke the operations, may take a `${NAME}` if the path contains a resource name
* scan (optional): a command to scan resources (by using this, the option may take an array of resource names)
* print (optional): an array of table definitions to print with `read-resource` operation.

Examples:

    ---
    description: Datasource Information
    path: ${DOMAIN_HOST}${DOMAIN_SERVER}/subsystem=datasources/data-source=${NAME}
    scan: ls ${DOMAIN_HOST}${DOMAIN_SERVER}/subsystem=datasources/data-source
    print:
      - id: config
        title: Datasource Details
        layout: vertical
        properties:
          - jndi-name
          - connection-url
          - driver-name
          - user-name
          - enabled
        header:
          - JNDI Name
          - Connection URL
          - Driver Name
          - User Name
          - Enabled
        format:
          enabled: boolean

        color:
          jndi_name:
            with: magenta
          enabled: boolean
          connection_url:
            with: yellow

      - id: pool
        title: Datasource Pool Statistics
        path: ${PATH}/statistics=pool
        layout: vertical
        properties:
          - ActiveCount
          - AvailableCount
          - AverageBlockingTime
          - AverageCreationTime
          - CreatedCount
          - DestroyedCount
          - MaxCreationTime
          - MaxUsedCount
          - MaxWaitTime
          - TimedOut
          - TotalBlockingTime
          - TotalCreationTime

        header:
          - Active
          - Available
          - Average Blocking
          - Average Creation
          - Created
          - Destroyed
          - Max Creation
          - Max Wait
          - Timed Out
          - Total Blocking
          - Total Creation

        health:
          active:
            percentage:
              max: available
              using: active

    ---
    description: Detail Server Information
    path: ${DOMAIN_HOST}${DOMAIN_SERVER}/core-service=
    print:
    - id: platform
      title: Operating System Information
      path: ${PATH}platform-mbean/type=operating-system
      properties:
      - name
      - arch
      - version
      - available-processors
      - system-load-average
      header:
      - Name
      - Arch
      - Version
      - Processors
      - System Load
      format:
        system_load: percentage
      color:
          name:
            with: bold.white
          system_load:
            threshold:
              0.8: bold.red
              0.7: red
              0.5: yellow
              0: green

To configure a table to print, just use the following parameters:

* id (required for multiple tables): a name that will be joined to the file name to allow print only this table
* title: the table title
* layout (horizontal | vertical): how the table must be printed. Use vertical for large number of properties
* properties: an array with the properties (returned by "read-resource") to print in this table, you can use a " -> " to navigate into nested properties (example: heap-memory-usage -> init)
* header: an array that maps a header text to the properties
* format: a hash that maps formatters to the table columns
* color: a hash that maps colors to the table columns
* health: a hash that maps health checkers to the table columns

All mappings (formatter, colorizer and health checker) should be mapped using the following conventions:

* the key should be the property name (replace '-' with '_')
* the value should be the message to send to `RBoss::Formatters`, `RBoss::HealthCheckers` or `RBoss::Colorizers`
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

To add new `Colorizers`, `Formatters` or `HealthCheckers`, just put the code in the `~/.rboss/rboss.rb` file.

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

* `/lib/rboss/view/colorizers.rb`
* `/lib/rboss/view/formatters.rb`
* `/lib/rboss/view/health_checkers.rb`
