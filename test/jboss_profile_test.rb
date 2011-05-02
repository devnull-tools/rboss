require_relative '../src/jboss_profile'

jboss_home = JBoss::Path::new "/home/ataxexe/jboss/eap/jboss-eap-5.1/jboss-as"
jboss_profile = JBoss::Profile::new jboss_home

jboss_profile.add :xa_datasource,
                  :type => :oracle,
                  :name => "production",
                  :folder => "#{jboss_home.profile.deploy.custom.datasource}",
                  :encrypt => true,
                  :attributes => {
                    :jndi_name => "Production",
                    :url => "jdbc:oracle:oci8:@production_db",
                    :user => "ora-xa",
                    :password => "pass-ora-xa"
                  }

jboss_profile.add :default_ds,
                  :type => :mysql,
                  :folder => "#{jboss_home.profile.deploy.custom.datasource}",
                  :attributes => {
                    :connection_url => "jdbc:mysql://localhost:3306/jbossdb",
                    :user_name => "root",
                    :password => "root"
                  }

jboss_profile.add :mod_cluster,
                  :advertise => false,
                  :proxy_list => "localhost:80,192.168.1.100:443",
                  :sticky_session => false,
                  :ssl => true

jboss_profile.add :bind,
                  :ports => 'ports-01',
                  :address => 'localhost'

jboss_profile.add :jmx,
                  :password => "jmx_admin_password"

jboss_profile.add :init_script,
                  :jboss_user => 'ataxexe'

jboss_profile.add :slimming, [
  :hot_deploy, :key_generator, :bsh_deployer, :jboss_ws, :mail, :juddi, :admin_console, :web_console, :jmx_console
]

jboss_profile.add :jms,
                  :peer_id => 2

jboss_profile.add :deploy_folder, "custom/apps"

jboss_profile.add :deploy_folder, "custom/datasource"

jboss_profile.create
