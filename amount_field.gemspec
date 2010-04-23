# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amount_field}
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Baustert"]
  s.date = %q{2010-04-23}
  s.description = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}
  s.email = %q{ business@thomasbaustert.de}
  s.extra_rdoc_files = ["README.rdoc", "lib/amount_field.rb", "lib/amount_field/configuration.rb", "lib/amount_field/form_helper.rb", "lib/amount_field/form_tag_helper.rb", "lib/amount_field/validations.rb"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest", "README.rdoc", "Rakefile", "amount_field.gemspec", "init.rb", "install.rb", "lib/amount_field.rb", "lib/amount_field/configuration.rb", "lib/amount_field/form_helper.rb", "lib/amount_field/form_tag_helper.rb", "lib/amount_field/validations.rb", "locale/de.yml", "locale/en.yml", "test/form_helper_test.rb", "test/form_tag_helper_test.rb", "test/models/test_product.rb", "test/test_helper.rb", "test/validations_test.rb", "uninstall.rb"]
  s.homepage = %q{http://github.com/thomasbaustert/amount_field}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Amount_field", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{amount_field}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Rails gem/plugin that accepts (amount) values in german or us format like 1.234,56 or 1,234.56}
  s.test_files = ["test/form_helper_test.rb", "test/form_tag_helper_test.rb", "test/models/test_product.rb", "test/test_helper.rb", "test/validations_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
