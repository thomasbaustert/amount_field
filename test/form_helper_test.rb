# -*- encoding: utf-8 -*-

require 'test_helper'

##
# Taken from the FormHelperTest in Rails 2.3
#
# We are testing the FormBuilder- and FormHelper-Version at once.
#
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
      form_for(@test_product, :as => :product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected_input =
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field' id='test_product_price' value='1.234,56' />"
    
      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

      assert_dom_equal expected_input, amount_field(:test_product, :price)
      assert_dom_equal expected_form, output_buffer
    end  
  end

  test "amount_field form helper with locale en" do
    with_locale('en') do
      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected_input =
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field' id='test_product_price' value='1,234.56' />"

      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

      assert_dom_equal expected_input, amount_field(:test_product, :price)
      assert_dom_equal expected_form, output_buffer
    end  
  end

  test "configured prefix is use in amount_field" do
    with_locale('de') do
      AmountField::Configuration.prefix = 'my_prefix'
      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected_input =
        "<input name='test_product[my_prefix_price]' size='30' type='text'" +
        " class=' amount_field' id='test_product_price' value='1.234,56' />"
      
      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"
      
      assert_dom_equal expected_input, amount_field(:test_product, :price)
      assert_dom_equal expected_form, output_buffer
      AmountField::Configuration.prefix = 'amount_field'
    end  
  end
  
  test "configured css class is use in amount_field" do
    with_locale('de') do
      AmountField::Configuration.css_class = 'my_class'
      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected_input =
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' my_class' id='test_product_price' value='1.234,56' />"

      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

      assert_dom_equal expected_input, amount_field(:test_product, :price)
      assert_dom_equal expected_form, output_buffer
      AmountField::Configuration.css_class = 'amount_field'
    end  
  end

  test "default configuration format overwrite I18n configuration" do
    with_configuration({ :delimiter => '@', :separator => '/', :precision => 2}) do
      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      expected_input =
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field' id='test_product_price' value='1@234/56' />"

      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

      assert_dom_equal expected_input, amount_field(:test_product, :price)
      assert_dom_equal expected_form, output_buffer
    end  
  end

  test "explicit format overwrite default configuration" do
    format = { :delimiter => '@', :separator => '/', :precision => 3 }
    with_locale('de') do
      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price, :format => format)
      end

      expected_input =
        "<input name='test_product[amount_field_price]' size='30' type='text'" +
        " class=' amount_field' id='test_product_price' value='1@234/560' />"

      expected_form =
        "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

      assert_dom_equal expected_input, amount_field(:test_product, :price, :format => format)
      assert_dom_equal expected_form, output_buffer
      assert_equal({}, AmountField::ActiveRecord::Validations.configuration)
    end                
  end
  
  test "we show the original value for an invalid value" do
    @test_product = TestProduct.new(:amount_field_price => "x")
    @test_product.valid?
    form_for(@test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price)
    end

    expected_input =
      "<div class='fieldWithErrors'>" +
      "<input name='test_product[amount_field_price]' size='30'" + 
      "       class=' amount_field' type='text' id='test_product_price' value='x' />" +
      "</div>" 

    expected_form =
      "<form action='http://www.example.com' method='post'>#{expected_input}</form>"

    assert_dom_equal expected_input, amount_field(:test_product, :price)
    assert_dom_equal expected_form, output_buffer
  end
  
  test "we show the given value instead of the invalid value" do
    @test_product = TestProduct.new(:amount_field_price => "x")
    @test_product.valid?
    form_for(@test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price, :value => 4711)
    end

    expected_input =
      "<div class='fieldWithErrors'>" +
      "<input name='test_product[amount_field_price]' size='30'" + 
      "       class=' amount_field' type='text' id='test_product_price' value='4711' />" +
      "</div>" 
    
    expected_form =
      "<form action='http://www.example.com' method='post'>#{expected_input}</form>"
      
    assert_dom_equal expected_input, amount_field(:test_product, :price, :value => 4711)
    assert_dom_equal expected_form, output_buffer
  end

  test "we use the object from options if given" do
    @test_product1 = TestProduct.new(:amount_field_price => "6543.21")
    @test_product1.valid?
    test_product2 = TestProduct.new(:amount_field_price => "1234.56")
    test_product2.valid?
    form_for(@test_product1, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price, :object => test_product2)
    end

    expected_input =
      "<input name='test_product[amount_field_price]' size='30'" + 
      "       class=' amount_field' type='text' id='test_product_price' value='1,234.56' />"
    
    expected_form =
      "<form action='http://www.example.com' method='post'>#{expected_input}</form>"
      
    assert_dom_equal expected_input, amount_field(:test_product, :price, :object => test_product2)
    assert_dom_equal expected_form, output_buffer
  end
  
  test "consider option name if given" do
    @test_product = TestProduct.new(:amount_field_price => "47.11")
    form_for(@test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price, :name => 'article')
    end

    expected_input =
      "<input name='article' size='30'" + 
      "       class=' amount_field' type='text' id='test_product_price' value='47.11' />"
    expected_form =
      "<form action='http://www.example.com' method='post'>#{expected_input}</form>"
    
    assert_dom_equal expected_input, amount_field(:test_product, :price, :name => 'article', :value => 47.11)
    assert_dom_equal expected_form, output_buffer
  end

  test "consider option id if given" do
    @test_product = TestProduct.new(:amount_field_price => "63.41")
    form_for(@test_product, :builder => MyFormBuilder) do |f|
      concat f.amount_field(:price, :name => 'article', :id => 'my_id')
    end

    expected_input =
      "<input name='article' size='30'" + 
      "       class=' amount_field' type='text' id='my_id' value='63.41' />"
    expected_form =
      "<form action='http://www.example.com' method='post'>#{expected_input}</form>"
    
    assert_dom_equal expected_input, amount_field(:test_product, :price, :name => 'article', :id => 'my_id', :value => 63.41)
    assert_dom_equal expected_form, output_buffer
  end

  test "invalid negative value is displayed with current format options" do
    with_locale('de') do
      class MyTestProduct < ActiveRecord::Base
        set_table_name 'test_products'
        validates_amount_format_of :price
        validates_numericality_of :price, :greater_than_or_equal_to => 0.0
      end
      @test_product = MyTestProduct.new(:amount_field_price => "-0,1")
      @test_product.valid?

      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      assert_match /value="-0,1"/, output_buffer
    end
  end

  test "invalid positive value is displayed with current format options" do
    with_locale('de') do
      class MyTestProduct < ActiveRecord::Base
        set_table_name 'test_products'
        validates_amount_format_of :price
        validates_numericality_of :price, :less_than_or_equal_to => 10.0
      end
      @test_product = MyTestProduct.new(:amount_field_price => "12,34")
      @test_product.valid?

      form_for(@test_product, :builder => MyFormBuilder) do |f|
        concat f.amount_field(:price)
      end

      assert_match /value="12,34"/, output_buffer
    end
  end
  
  protected
  
    def protect_against_forgery?
      false
    end
    
end
