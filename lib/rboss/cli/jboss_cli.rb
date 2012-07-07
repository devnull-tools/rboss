require_relative 'component'

module JBoss

  module Cli

    class Invoker

      attr_reader :server, :host, :port, :user, :password
      attr_accessor :command

      def initialize(params = {})
        params = {
          :jboss_home => ENV["JBOSS_HOME"],
          :server => nil,
          :host => '127.0.0.1',
          :port => 9999,
          :user => "admin",
          :password => "jboss"
        }.merge! params

        @jboss_home = params[:jboss_home]

        @server = params[:server]
        @host = params[:host]
        @port = params[:port]
        @server ||= [@host, @port].join ':'

        @user = params[:user]
        @password = params[:password]

        @command = "#@jboss_home/bin/jboss-cli.sh --connect --controller=#@server --user='#@user' --password='#@password'"

        @mappings = {
          :datasource => {
            :path => '/subsystem=datasources/data-source=[NAME]',
            :scan => 'ls [PATH]',

            :print_details => {
              :description => 'Datasource Details',
              :properties => %w{connection-url driver-name enabled},
              :header => ["Connection URL", "Driver Name", "Enabled"],
              :command => '[PATH]:read-resource',
            },
            :print_metrics =>
              [{
                 :description => 'Datasource Pool Metrics',
                 :command => '[PATH]/statistics=pool:read-resource(include-runtime=true)',
                 :properties => %w{ActiveCount AvailableCount},
                 :header => %W(Active\nCount Available\nCount)
               },
               {
                 :description => 'Datasource JDBC Metrics',
                 :command => '[PATH]/statistics=jdbc:read-resource(include-runtime=true)',
                 :properties => %w{PreparedStatementCacheAccessCount PreparedStatementCacheAddCount},
                 :header => %W{Access\nCount Add\nCount}
               }]
          }
        }
      end

      def print(components)
        components.each do |key, resources|
          if @mappings.has_key? key
            mapping = @mappings[key]
            component = Component::new(self, mapping)
            component.print resources
          end
        end
      end

      def execute(*commands)
        exec = "#@command --commands=\"#{commands.join ','}\""
        `#{exec}`.chomp
      end

    end

  end

end
