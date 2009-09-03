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
  
  test "amount_field form helper with locale de" do
    with_locale('de') do
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
  end

  test "amount_field form helper with locale en" do
    with_locale('en') do
      form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end
    
      expected =
        "<form action='http://www.example.com' method='post'>" +
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' #{AmountField::Configuration.css_class}'" +
        " id='test_product_price' value='1,234.56' />" +
        "</form>"

      assert_dom_equal expected, output_buffer
    end  
  end

  test "configured prefix is use in amount_field" do
    with_locale('de') do
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
  end
  
  test "configured css class is use in amount_field" do
    with_locale('de') do
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
  end

  test "default configuration format overwrite I18n configuration" do
    with_configuration({ :delimiter => '@', :separator => '/', :precision => 2}) do
      form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected =
        "<form action='http://www.example.com' method='post'>" +
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field'" +
        " id='test_product_price' value='1@234/56' />" +
        "</form>"

      assert_dom_equal expected, output_buffer
    end  
  end

  test "explicit format overwrite default configuration" do
    with_locale('de') do
      
      form_for(:test_product, @test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price, :format => { :delimiter => '@', :separator => '/', :precision => 3})
      end

      expected =
        "<form action='http://www.example.com' method='post'>" +
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field'" +
        " id='test_product_price' value='1@234/560' />" +
        "</form>"

      assert_dom_equal expected, output_buffer
      assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
    end                
  end
  
  test "we show the original value for an invalid value" do
    test_product = TestProduct.new(:amount_field_price => "x")
    test_product.valid?
    form_for(:test_product, test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price)
    end

    expected =
      "<form action='http://www.example.com' method='post'>" + 
      "<div class='fieldWithErrors'><input name='test_product[amount_field_price]' size='30'" + 
      " class=' amount_field' type='text' id='test_product_price' value='x' /></div>" + 
      "</form>"

    assert_dom_equal expected, output_buffer
    assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
  end
  
  test "we show the given value instead of the invalid value" do
    test_product = TestProduct.new(:amount_field_price => "x")
    test_product.valid?
    form_for(:test_product, test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price, :value => 4711)
    end

    expected =
      "<form action='http://www.example.com' method='post'>" + 
      "<div class='fieldWithErrors'><input name='test_product[amount_field_price]' size='30'" + 
      " class=' amount_field' type='text' id='test_product_price' value='4711' /></div>" + 
      "</form>"

    assert_dom_equal expected, output_buffer
    assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
  end
  
  protected
  
    def protect_against_forgery?
      false
    end
    
end
