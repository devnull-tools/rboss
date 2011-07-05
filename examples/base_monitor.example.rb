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
opts.on('-s', '--jboss-ip [ip]', 'Defines the JBoss ip') { |ip| params[:jboss_ip] = ip }
opts.on('-l', '--jboss-port [port]', 'Defines the JBoss jnp port') { |port| params[:jboss_port] = port }
opts.on('-u', '--jmx-user [user]', 'Defines the JMX User') { |user| params[:jmx_user] = user }
opts.on('-p', '--jmx-password [password]', 'Defines the JMX Password') { |password| params[:jmx_password] = password }
opts.on("-h", "--help", "Show this help message") { puts opts; exit }
opts.parse!(ARGV) rescue abort 'Invalid Option'

twiddle = JBoss::Twiddle::Invoker::new params
monitor = JBoss::Twiddle::BaseMonitor::new twiddle

while true do
  puts "Server Info:"
  puts "\t- FreeMemory=#{monitor.server_info(:property => 'FreeMemory').value.to_i / (1024 * 1024)}MB"
  puts "\t- #{monitor.server_info :property => 'ActiveThreadCount'}"
  puts "Connectors:"

  monitor.with :connectors do |connector|
    puts "\t- #{connector}"
    monitor.properties[:connector].each do |property|
      puts "\t\t- #{monitor.connector[property]}"
    end
    monitor.properties[:request].each do |property|
      puts "\t\t- #{monitor.request[property]}"
    end
  end

  puts "Datasources:"

  monitor.with :datasources do |datasource|
    puts "\t- #{datasource}"
    monitor.properties[:datasource].each do |property|
      puts "\t\t- #{monitor.datasource[property]}"
    end
  end

  puts "Webapp:"

  monitor.with :webapps do |webapp|
    puts "\t- #{webapp}"
    monitor.properties[:webapp].each do |property|
      puts "\t\t- #{monitor.webapp[property]}"
    end
  end

  sleep 10

  puts
  puts
  puts
end
