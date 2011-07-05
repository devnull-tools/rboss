require '../src/rboss'

include JBoss

profile = Profile::new "#{ENV["HOME"]}/jboss/soa-p/jboss-soa-p-5/jboss-as",
                       :type         => :soa_p,
                       :version      => 5,
                       :base_profile => :all,
                       :profile      => :dev

profile.add :jmx
profile.add :deploy_folder, 'deploy/datasources'
profile.add :deploy_folder, 'deploy/apps'
profile.add :default_ds,
            "source.dir"  => :postgresql84,
            "db.name"     => :jboss_soap_db,
            "db.hostname" => :localhost,
            "db.port"     => 5432,
            "db.username" => :postgres,
            "db.password" => :postgres

profile.add :resource, 'lib/postgresql-8.4-x.jdbc4.jar' => '/home/ataxexe/jdbc/postgresql/postgresql.jar'

profile.install :mod_cluster

profile.add :run_conf, :heap_size => '1024m', :perm_size => '512m'

profile.create
