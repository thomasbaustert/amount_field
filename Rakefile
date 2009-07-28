# require 'rake'
# require 'rake/testtask'
# require 'rake/rdoctask'
# 
# desc 'Default: run unit tests.'
# task :default => :test
# 
# desc 'Test the amount_field plugin.'
# Rake::TestTask.new(:test) do |t|
#   t.libs << 'lib'
#   t.libs << 'test'
#   t.pattern = 'test/**/*_test.rb'
#   t.verbose = true
# end
# 
# desc 'Generate documentation for the amount_field plugin.'
# Rake::RDocTask.new(:rdoc) do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'AmountField'
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end

require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('amount_field', '1.0.0') do |p|
  p.description   = "Allows amount value in german or us format like 1.234,56 or 1,234.56"
  p.url           = "git@github.com:thomasbaustert/amount_field.git"
  p.author        = "Thomas Baustert"
  p.email         =" business@thomasbaustert.de"
  p.ignore_pattern = ["tmp/*", "script/*"]
  p.development_dependencies = []
end
