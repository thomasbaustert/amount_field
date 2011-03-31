# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "amount_field/version"

Gem::Specification.new do |s|
  s.name        = "amount_field_rails3"
  s.version     = Lorem::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Baustert"]
  s.email       = ["business@thomasbaustert.de"]
  s.homepage    = "http://github.com/thomasbaustert/amount_field"
  s.summary     = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}
  s.description = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}

  s.rubyforge_project = "amount_field_rails3"

  s.add_dependency "mysql2"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end


