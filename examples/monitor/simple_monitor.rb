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
