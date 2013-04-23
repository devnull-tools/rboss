# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rboss/version"

Gem::Specification.new do |s|
  s.name        = "rboss"
  s.version     = RBoss::VERSION
  s.authors     = ["Ataxexe"]
  s.email       = ["ataxexe@gmail.com"]
  s.homepage    = "https://github.com/ataxexe/rboss"
  s.summary     = %q{Manage your JBoss from your command line.}
  s.description = %q{Rboss gives you a set of command line tools to configure a JBoss instance
  and use jboss-cli and twiddle wrapped by an elegant interface}

  s.rubyforge_project = "rboss"

  s.add_dependency 'yummi', '>=0.8.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
