# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{amount_field}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Baustert"]
  s.date = %q{2009-08-31}
  s.description = %q{Allows amount value in german or us format like 1.234,56 or 1,234.56}
  s.email = %q{ business@thomasbaustert.de}
  s.extra_rdoc_files = ["lib/amount_field/configuration.rb", "lib/amount_field/form_helper.rb", "lib/amount_field/form_tag_helper.rb", "lib/amount_field/validations.rb", "lib/amount_field.rb", "README.rdoc"]
  s.files = ["History.txt", "init.rb", "install.rb", "lib/amount_field/configuration.rb", "lib/amount_field/form_helper.rb", "lib/amount_field/form_tag_helper.rb", "lib/amount_field/validations.rb", "lib/amount_field.rb", "locale/de.yml", "locale/en.yml", "MIT-LICENSE", "Rakefile", "README.rdoc", "test/form_helper_test.rb", "test/form_tag_helper_test.rb", "test/models/test_product.rb", "test/test_helper.rb", "test/validations_test.rb", "uninstall.rb", "Manifest", "amount_field.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{git@github.com:thomasbaustert/amount_field.git}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Amount_field", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{amount_field}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Allows amount value in german or us format like 1.234,56 or 1,234.56}
  s.test_files = ["test/form_helper_test.rb", "test/form_tag_helper_test.rb", "test/models/test_product.rb", "test/test_helper.rb", "test/validations_test.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
