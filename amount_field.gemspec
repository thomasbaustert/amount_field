# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amount_field}
  s.version = "1.4.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Thomas Baustert}]
  s.date = %q{2011-11-07}
  s.description = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}
  s.email = %q{ business@thomasbaustert.de}
  s.extra_rdoc_files = [%q{README.rdoc}, %q{lib/amount_field.rb}, %q{lib/amount_field/configuration.rb}, %q{lib/amount_field/form_helper.rb}, %q{lib/amount_field/form_tag_helper.rb}, %q{lib/amount_field/validations.rb}]
  s.files = [%q{History.txt}, %q{MIT-LICENSE}, %q{Manifest}, %q{README.rdoc}, %q{Rakefile}, %q{amount_field.gemspec}, %q{init.rb}, %q{install.rb}, %q{lib/amount_field.rb}, %q{lib/amount_field/configuration.rb}, %q{lib/amount_field/form_helper.rb}, %q{lib/amount_field/form_tag_helper.rb}, %q{lib/amount_field/validations.rb}, %q{locale/de.yml}, %q{locale/en.yml}, %q{test/form_helper_test.rb}, %q{test/form_tag_helper_test.rb}, %q{test/models/test_product.rb}, %q{test/test_helper.rb}, %q{test/validations_test.rb}, %q{uninstall.rb}]
  s.homepage = %q{http://github.com/thomasbaustert/amount_field}
  s.rdoc_options = [%q{--line-numbers}, %q{--inline-source}, %q{--title}, %q{Amount_field}, %q{--main}, %q{README.rdoc}]
  s.require_paths = [%q{lib}]
  s.rubyforge_project = %q{amount_field}
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}
  s.test_files = [%q{test/form_helper_test.rb}, %q{test/form_tag_helper_test.rb}, %q{test/models/test_product.rb}, %q{test/test_helper.rb}, %q{test/validations_test.rb}]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
