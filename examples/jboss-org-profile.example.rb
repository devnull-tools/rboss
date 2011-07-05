require_relative '../src/rboss'

include JBoss

profile = Profile::new "#{ENV["HOME"]}/jboss/org/jboss-5.1",
                       :type         => :org,
                       :version      => 5.1,
                       :base_profile => :default,
                       :profile      => :dev

profile.configure :jmx, :password => "admin"

profile.add :deploy_folder, 'deploy/datasources'
profile.add :deploy_folder, 'deploy/apps'

profile.configure :run_conf, :heap_size => '1024m', :perm_size => '512m', :debug => :socket

profile.create
