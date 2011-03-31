ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../../../../config/environment")
require 'rails/test_help'

require File.join(File.dirname(__FILE__), '../init')
Dir[File.join(File.dirname(__FILE__), 'models/*.rb')].each { |f| require f }

ActiveRecord::Base.establish_connection({
  :adapter  => 'mysql2',
  :database => 'gem_amount_field_test',
  :host     => 'localhost',
  :username => 'root',
  :password => '' 
})

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table "test_products", :force => true do |t|    
    t.column "name", :string
    t.column "price", :decimal, :precision => 12, :scale => 2
    t.column "stock_price", :decimal, :precision => 12, :scale => 2
    t.column "float_price", :float
  end
end

class ActiveSupport::TestCase

  def with_configuration(config)
    begin
      orig_config = AmountField::ActiveRecord::Validations.configuration
      AmountField::ActiveRecord::Validations.configuration = config
      yield 
    ensure
      AmountField::ActiveRecord::Validations.configuration = orig_config
    end
  end
  
  def with_locale(locale)
    begin
      orig_locale = I18n.locale
      I18n.locale = locale
      yield 
    ensure
      I18n.locale = orig_locale
    end
  end

  def assert_valid_formats(formats, test_clazz)
    formats.each do |format, expected_value|
      product = test_clazz.new(:amount_field_price => format)
      assert product.valid?, "expected '#{format}' to be valid (#{product.errors.full_messages.inspect})"
      assert_in_delta expected_value, product.price.to_f, 0.001
    end
  end
  
  def assert_invalid_formats(formats, test_clazz)
    formats.each do |format| 
      product = test_clazz.new(:amount_field_price => format)
      assert !product.valid?, "expected '#{format}' to be invalid (#{product.errors.full_messages.inspect})"
    end
  end
      
end  
