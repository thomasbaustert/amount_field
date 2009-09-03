require File.join(File.dirname(__FILE__), 'test_helper')

class FormTagHelperTest < ActiveSupport::TestCase
  include ActionView::Helpers::FormTagHelper # includes 'amount_field_tag'
  include ActionView::Helpers::TagHelper

  test "return an input field with the special amount field name attribute" do
    @test_product = TestProduct.new(:price => 1234.56)
    assert_match /name="test_product\[amount_field_price\]"/, amount_field_tag(:test_product, :price)
  end

  test "return an value attribute with a formatted value for german locale" do
    with_locale('de') do
      @test_product = TestProduct.new(:price => 1234.56)
      assert_match /value="1.234,56"/, amount_field_tag(:test_product, :price)
    end
  end

  test "return an value attribute with a formatted value for english locale" do
    with_locale('en') do
      @test_product = TestProduct.new(:price => 1234.56)
      assert_match /value="1,234.56"/, amount_field_tag(:test_product, :price)
    end
  end

  test "default css class is used in combination with given class" do
    @test_product = TestProduct.new(:price => 1234.56)
    assert_match /class="foo #{AmountField::Configuration.css_class}"/, amount_field_tag(:test_product, :price, :class => 'foo')
  end
  
  test "configured prefix is use in amount_field" do
    AmountField::Configuration.prefix = 'my_prefix'
    @test_product = TestProduct.new(:price => 1234.56)
    assert_match /name="test_product\[my_prefix_price\]"/, amount_field_tag(:test_product, :price)
    AmountField::Configuration.prefix = 'amount_field'
  end

  test "configured css class is use in amount_field" do
    AmountField::Configuration.css_class = 'my_class'
    @test_product = TestProduct.new(:price => 1234.56)
    assert_match /class=" my_class"/, amount_field_tag(:test_product, :price)
    AmountField::Configuration.css_class = 'amount_field'
  end

  test "explicit format overwrite default configuration" do
    @test_product = TestProduct.new(:price => 1234.56)
    assert_match /value="1@234#560"/, amount_field_tag(:test_product, :price, :format => { :delimiter => '@', :separator => '#', :precision => 3})
    assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
  end
  
  test "we show the original value for an invalid value" do
    @test_product = TestProduct.new(:amount_field_price => "x")
    @test_product.valid?
    assert_match /value="x"/, amount_field_tag(:test_product, :price)
  end

  test "we show the given value instead of the invalid value" do
    @test_product = TestProduct.new(:amount_field_price => "x")
    @test_product.valid?
    assert_match /value="42"/, amount_field_tag(:test_product, :price, :value => 42)
  end
  
end
