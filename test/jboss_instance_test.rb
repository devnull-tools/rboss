require_relative '../src/jboss_instance'

jboss_home = JBoss::new "/home/ataxexe/jboss/eap/jboss-eap-5.1/jboss-as"
jboss_instance = JBossInstance::new jboss_home

`rm -rf #{jboss_home.instance}`
`rm -f #{jboss_home.bin}/jboss_init_#{jboss_home.instance_name}.sh`

jboss_instance.add :xa_datasource,
                   :type => :oracle,
                   :name => "production",
                   :folder => "#{jboss_home.instance.deploy.custom.datasource}",
                   :encrypt => true,
                   :attributes => {
                     :jndi_name => "Production",
                     :url => "jdbc:oracle:oci8:@production_db",
                     :user => "ora-xa",
                     :password => "pass-ora-xa"
                   }

jboss_instance.add :default_ds,
                   :type => :mysql,
                   :folder => "#{jboss_home.instance.deploy.custom.datasource}",
                   :attributes => {
                     :connection_url => "jdbc:mysql://localhost:3306/jbossdb",
                     :user_name => "root",
                     :password => "root"
                   }

jboss_instance.add :mod_cluster,
                   :advertise => false,
                   :proxy_list => "localhost:80,192.168.1.100:443",
                   :sticky_session => false,
                   :ssl => true

jboss_instance.add :bind,
                   :ports => 'ports-01',
                   :address => 'localhost'

jboss_instance.add :init_script,
                   :jboss_user => 'ataxexe'

jboss_instance.add :slimming, :remove => [
  :hot_deploy, :bsh_deployer, :jboss_ws, :mail, :juddi, :admin_console, :web_console, :jmx_console
]

jboss_instance.add :jms,
                   :peer_id => 2

jboss_instance.add :deploy_folder,
                   :folder => "custom/apps"

jboss_instance.add :deploy_folder,
                   :folder => "custom/datasource"

jboss_instance.create

#TODO make the assertions
