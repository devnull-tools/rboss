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

puts "Server Info:"
monitor.properties[:server_info].each do |property|
  puts "  |--> #{monitor.server_info[property]}"
end

puts "Connectors:"

monitor.with :connectors do |connector|
  puts "  |--> #{connector}"
  monitor.properties[:connector].each do |property|
    puts "    |--> #{monitor.connector[property]}"
  end
  monitor.properties[:request].each do |property|
    puts "    |--> #{monitor.request[property]}"
  end
end

puts "Datasources:"

monitor.with :datasources do |datasource|
  puts "  |--> #{datasource}"
  monitor.properties[:datasource].each do |property|
    puts "    |--> #{monitor.datasource[property]}"
  end
end

puts "Webapps:"

monitor.with :webapps do |webapp|
  puts "  |--> #{webapp}"
  monitor.properties[:webapp].each do |property|
    puts "    |--> #{monitor.webapp[property]}"
  end
end

puts "Queues:"

monitor.with :queues do |queue|
  puts "  |--> #{queue}"
  monitor.properties[:queue].each do |property|
    puts "    |--> #{monitor.queue[property]}"
  end
end
