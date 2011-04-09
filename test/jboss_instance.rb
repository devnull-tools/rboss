require_relative '../src/jboss_instance'

jboss = JBossInstance::new "/home/ataxexe/jboss/eap/jboss-eap-5.1/jboss-as",
                           :base_instance => :all,
                           :custom_instance => :test

`rm -rf /home/ataxexe/jboss/eap/jboss-eap-5.1/jboss-as/server/test`

jboss.create

jboss.add :resource,
          "lib" => ["/opt/jdbc/mysql/mysql.jar", "/opt/jdbc/postgresql/postgresql.jar"]

jboss.add :default_ds,
          :type => :mysql,
          :folder => "custom/datasource",
          :name => 'mysql-jboss',
          :attributes => {
            :connection_url => "jdbc:mysql://localhost:3306/jbossdb",
            :user_name => "root",
            :password => "root"
          }

jboss.add :mod_cluster

jboss.add :slimming, :remove => [
  :bsh_deployer, :jboss_ws, :mail, :juddi, :web_console
]

jboss.add :jms,
          :peer_id => 1

jboss.add :deploy_folder,
          :folder => "custom/apps"

jboss.add :deploy_folder,
          :folder => "custom/datasource"

jboss.add :run_conf,
          :perm_size => '1024m'

jboss.configure
