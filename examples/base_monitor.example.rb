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

twiddle = JBoss::Twiddle::Invoker::new
monitor = JBoss::Twiddle::BaseMonitor::new twiddle

info = []
info << "Server Info:"
info << "\t- FreeMemory=#{monitor.server_info(:property => 'FreeMemory').value.to_i / (1024 * 1024)}MB"
info << "\t- #{monitor.server_info :property => 'ActiveThreadCount'}"
info << "Connectors:"

%W(http:8080 ajp:8009).each do |connector|
  monitor.with connector do
    info << "\t- #{connector}"
    monitor.properties[:connector].each do |property|
      info << "\t\t- #{monitor.connector[property]}"
    end
    monitor.properties[:request].each do |property|
      info << "\t\t- #{monitor.request[property]}"
    end
  end
end

info << "Datasource DefaultDS:"

monitor.with 'DefaultDS' do
  monitor.properties[:datasource].each do |property|
    info << "\t- #{monitor.datasource[property]}"
  end
end

info << "Webapp jmx-console"

monitor.with 'jmx-console' do
  monitor.properties[:webapp].each do |property|
    info << "\t- #{monitor.webapp[property]}"
  end
end

puts info.join "\n"
