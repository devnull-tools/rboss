# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rboss/version"

Gem::Specification.new do |s|
  s.name        = "rboss"
  s.version     = RBoss::VERSION
  s.authors     = ["Ataxexe"]
  s.email       = ["ataxexe@gmail.com"]
  s.homepage    = "https://github.com/ataxexe/rboss"
  s.summary     = %q{A Ruby way to do a JBoss work!}
  s.description = %q{Rboss gives you an automate tool to configure a JBoss instance
  and a nice command line front end to use jboss-cli and twiddle}

  s.rubyforge_project = "rboss"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
