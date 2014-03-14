# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rboss/version'

Gem::Specification.new do |gem|
  gem.name        = 'rboss'
  gem.version     = RBoss::VERSION
  gem.authors     = %w(Ataxexe)
  gem.email       = %w(ataxexe@gmail.com)
  gem.homepage    = 'https://github.com/ataxexe/rboss'
  gem.summary     = %q{Manage your JBoss from your command line.}
  gem.description = %q{Rboss gives you a set of command line tools to configure a JBoss instance
  and use jboss-cli and twiddle wrapped by an elegant interface}

  gem.rubyforge_project = 'rboss'

  gem.add_dependency 'yummi', '>= 0.9.3'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = %w(lib)
end
