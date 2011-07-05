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

require_relative '../src/rboss'
require 'optparse'

params = {}

opts = OptionParser::new
opts.on('-j', '--jboss-home [path]', 'Defines the JBOSS_HOME variable') { |home| params[:jboss_home] = home }
opts.on('-t', '--type [type]', 'Defines the JBoss Type (org, eap, soa_p, epp)') { |type| params[:type] = type }
opts.on('-v', '--version [version]', 'Defines the JBoss version (5, 6, 5.1, 5.0.1)') { |version| params[:version] = version }
opts.on('-b', '--base-profile [profile]', 'Defines the JMX User') { |profile| params[:base_profile] = profile }
opts.on('-p', '--profile [profile]', 'Defines the JMX Password') { |profile| params[:profile] = profile }
opts.on("-h", "--help", "Show this help message") { puts opts; exit }
#TODO make an option for reading an yaml with profile configuration
opts.parse!(ARGV) rescue abort 'Invalid Option'

include JBoss

profile = Profile::new params

profile.configure :jmx, :password => "admin"

profile.add :deploy_folder, 'deploy/datasources'
profile.add :deploy_folder, 'deploy/apps'

profile.configure :run_conf, :heap_size => '1024m', :perm_size => '512m', :debug => :socket

profile.create
