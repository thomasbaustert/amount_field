require File.join(File.dirname(__FILE__), 'test_helper')

# Taken from the FormHelperTest in Rails 2.3

class FormHelperTest < ActionView::TestCase
  tests AmountField::Helpers::FormHelper

  class MyFormBuilder < ActionView::Helpers::FormBuilder
  end

  def setup
    @controller = Class.new do
      attr_reader :url_for_options
      def url_for(options)
        @url_for_options = options
        "http://www.example.com"
      end
    end
    @controller = @controller.new
    @test_product = TestProduct.new(:price => 1234.56)
  end
  
  test "amount_field form helper" do
    form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price)
    end
    
    expected =
      "<form action='http://www.example.com' method='post'>" +
      "<input name='test_product[amount_field_price]' size='30' type='text'" +
      " class=' #{AmountField::Configuration.css_class}'" +
      " id='test_product_price' value='1.234,56' />" +
      "</form>"

    assert_dom_equal expected, output_buffer
  end

  test "configured prefix is use in amount_field" do
    AmountField::Configuration.prefix = 'my_prefix'
    form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price)
    end

    expected =
      "<form action='http://www.example.com' method='post'>" +
      "<input name='test_product[my_prefix_price]' size='30' type='text'" +
      " class=' amount_field'" +
      " id='test_product_price' value='1.234,56' />" +
      "</form>"

    assert_dom_equal expected, output_buffer
    AmountField::Configuration.prefix = 'amount_field'
  end
  
  test "configured css class is use in amount_field" do
    AmountField::Configuration.css_class = 'my_class'
    form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price)
    end

    expected =
      "<form action='http://www.example.com' method='post'>" +
      "<input name='test_product[amount_field_price]' size='30' type='text'" +
      " class=' my_class'" +
      " id='test_product_price' value='1.234,56' />" +
      "</form>"

    assert_dom_equal expected, output_buffer
    AmountField::Configuration.css_class = 'amount_field'
  end
  
  protected
  
    def protect_against_forgery?
      false
    end
    
end
