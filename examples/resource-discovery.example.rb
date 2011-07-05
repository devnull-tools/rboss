require_relative '../src/rboss'

discovery = JBoss::Twiddle::ResourceDiscovery::new

puts "Webapps:"
puts discovery.webapps

puts "\nDatasources:"
puts discovery.datasources

puts "\nConnectors:"
puts discovery.connectors
