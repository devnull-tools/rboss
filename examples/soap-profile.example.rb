#                         The MIT License
#
# Copyright (c) 2011 Marcelo Guimarães <ataxexe@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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

profile.add :resource, 'lib/postgresql-8.4-x.jdbc4.jar' => "#{ENV["HOME"]}/jdbc/postgresql/postgresql.jar"

profile.install :mod_cluster

profile.add :run_conf, :heap_size => '1024m', :perm_size => '512m'

profile.create
