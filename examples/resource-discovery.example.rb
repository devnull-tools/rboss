require_relative '../src/rboss'

discovery = JBoss::Twiddle::ResourceDiscoverer::new

puts "Webapps:"
puts discovery.webapps

puts "\nDatasources:"
puts discovery.datasources

puts "\nConnectors:"
puts discovery.connectors
