# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rboss/version"

Gem::Specification.new do |s|
  s.name        = "rboss"
  s.version     = RBoss::VERSION
  s.authors     = ["Ataxexe"]
  s.email       = ["ataxexe@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{A Ruby way to do a JBoss work!}
  s.description = %q{This gem help you to create a JBoss profile and some other things like building twiddle scripts}

  s.add_dependency "erb"

  s.rubyforge_project = "rboss"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
