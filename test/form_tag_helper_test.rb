require File.join(File.dirname(__FILE__), 'test_helper')

class FormTagHelperTest < ActionView::TestCase
  tests AmountField::Helpers::FormTagHelper

  test "return an input field with the special amount field name attribute" do
    assert_match /name="amount_field_price"/, amount_field_tag(:price, 1234.56)
  end

  test "return an value attribute with a formatted value for german locale" do
    with_locale('de') do
      assert_match /value="1.234,56"/, amount_field_tag(:price, 1234.56)
    end
  end

  test "return an value attribute with a formatted value for english locale" do
    with_locale('en') do
      assert_match /value="1,234.56"/, amount_field_tag(:price, 1234.56)
    end
  end

  test "default css class is used in combination with given class" do
    assert_match /class="foo #{AmountField::Configuration.css_class}"/, amount_field_tag(:price, 1234.56, :class => 'foo')
  end
  
  test "configured prefix is use in amount_field" do
    AmountField::Configuration.prefix = 'my_prefix'
    assert_match /name="my_prefix_price"/, amount_field_tag(:price, 1234.56)
    AmountField::Configuration.prefix = 'amount_field'
  end

  test "configured css class is use in amount_field" do
    AmountField::Configuration.css_class = 'my_class'
    assert_match /class=" my_class"/, amount_field_tag(:price, 1234.56)
    AmountField::Configuration.css_class = 'amount_field'
  end

  test "explicit format overwrite default configuration" do
    assert_match /value="1@234#560"/, amount_field_tag(:price, 1234.56, :format => { :delimiter => '@', :separator => '#', :precision => 3})
    assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
  end
  
  test "we show the given value from the options instead of the argument" do
    assert_match /value="42"/, amount_field_tag(:price, 1234.56, :value => 42)
  end
  
end
