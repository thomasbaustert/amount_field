require File.join(File.dirname(__FILE__), 'test_helper')

class ValidationsTest < ActiveSupport::TestCase

  test "orignal setter accept ruby value if set via new" do
    product = TestProduct.new(:price => 12.34)
    assert_in_delta 12.34, product.price, 0.001
  end

  test "orignal setter accept ruby value" do
    product = TestProduct.new
    product.price = 12.34
    assert_in_delta 12.34, product.price, 0.001
  end

  test "price is valid for loaded record" do
    product = TestProduct.create!(:price => 12.34)
    assert_in_delta 12.34, product.price, 0.001
  end

  test "special setter does not accept a decimal value" do
    # special case. The value is assign via the special setter as a decimal not as a string.
    # The validation fails because the value is not of the german format '1234,56' and therefore
    # the price should be 0.0 (not assiged), but it is set to 1234.56. We dont handle this rare
    # case, because the value for the special setter is mostly a string
    product = TestProduct.new
    product.amount_field_price = 1234.56
    assert !product.valid?, "expect 1234.56 to be invalid (#{product.errors.full_messages.inspect})"
    assert_in_delta 1234.56, product.price.to_f, 0.001
  end

  test "special setter accept german format value" do
    with_locale('de') do
      product = TestProduct.new
      product.amount_field_price = '1.234,56'
      assert product.valid?, "expect '1.234,56' to be valid (#{product.errors.full_messages.inspect})"
      assert_in_delta 1234.56, product.price, 0.001
    end  
  end

  test "accept valid german formats" do
    class TestProductValidGermanFormat < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    with_locale('de') do
      assert_valid_formats({',00' => 0.0, '1,00' => 1.0, '12,00' => 12.0, '123,00' => 123.0, '1234,00' => 1234.0, 
                            '1.234,56' => 1234.56, '12.345,00' => 12345.0, '123.456,00' => 123456.0, 
                            '1.234.567,00' => 1234567.00 }, TestProductValidGermanFormat)
    end                        
  end
  
  test "accept valid us formats" do
    with_configuration({ :separator => '.', :delimiter => ',', :precision => 2 }) do
      class TestProductValidUsFormat < ActiveRecord::Base
        set_table_name 'test_products'
        validates_amount_format_of :price
      end

      assert_valid_formats({'.00' => 0.0, '1.00' => 1.0, '12.00' => 12.0, '123.00' => 123.0, '1234.00' => 1234.0, 
                            '1,234.56' => 1234.56, '12,345.00' => 12345.0, '123,456.00' => 123456.0, 
                            '1,234,567.00' => 1234567.00 }, TestProductValidUsFormat)
    end                            
  end

  test "dont accept invalid formats" do
    class TestProductInValidGermanFormat < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    with_locale('de') do
      assert_invalid_formats(['1234.567.890,12', '123.4567.890,12', '1,2.34', '1,2,3', '1.23,45', 
                              '1.23.45,6', '2,1x', '2,x', 'x2', '', nil], TestProductInValidGermanFormat)
    end                          
  end

  test "accept only values of format with the defined configuration" do
    class TestProductConfiguration < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :separator => '.', :delimiter => ','
      validates_amount_format_of :stock_price, :separator => ',', :delimiter => '.'
    end

    product = TestProductConfiguration.new(:amount_field_price => '1,234,567.891', 
                                           :amount_field_stock_price => '1.234.567,892')
    assert product.valid?
    assert_in_delta 1234567.891, product.price, 0.001
    assert_in_delta 1234567.892, product.stock_price, 0.001
  end

  test "accept only values of format with the defined precision" do
    class TestProductPrecision < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price # default 3
      validates_amount_format_of :stock_price, :precision => 1
    end

    product = TestProductPrecision.new(:amount_field_price => '1,234.567', 
                                       :amount_field_stock_price => '1,234.5')
    assert product.valid?
    assert_in_delta 1234.567, product.price, 0.001
    assert_in_delta 1234.500, product.stock_price, 0.001
  end

  test "accept only integer if precision is 0 or nil" do
    class TestProductInteger < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :precision => 0, :separator => nil
    end

    with_locale('de') do
      assert_valid_formats({'0' => 0.0, '1' => 1.0, '12' => 12.0, '123' => 123.0, '1.234' => 1234.0}, TestProductInteger)
      assert_invalid_formats(['1,', '1,0', '1,2', '1,23'], TestProductInteger)
    end  
  end

  test "accept only values with no delimiter" do
    class TestProductNoDelimiter < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :separator => '.', :delimiter => nil
    end

    with_locale('de') do
      assert_valid_formats({'.00' => 0.0, '1.00' => 1.0, '12.00' => 12.0, '123.00' => 123.0, '1234.00' => 1234.0, '12345.00' => 12345.0, '123456.00' => 123456.0}, TestProductNoDelimiter)
      assert_invalid_formats(['1,234.56', '123,456.00'], TestProductNoDelimiter)
    end
  end

  test "use english default message" do
    class TestProductEnglishMessage < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    with_locale('en') do
      product = TestProductEnglishMessage.new(:amount_field_price => 'x')
      assert !product.valid?
      assert_equal "'x' is not a valid amount format (d,ddd.ddd)", product.errors.on(:price)
    end  
  end

  test "use german default message" do
    class TestProductGermanMessage < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    with_locale('de') do
      product = TestProductGermanMessage.new(:amount_field_price => 'x')
      assert !product.valid?
      assert_equal "'x' ist ein ungültiges Format (d.ddd,dd)", product.errors.on(:price)
    end
  end

  test "validates_amount_format_of use given message" do
    class TestProductGivenMessage < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :message => "special message {{value}}"
    end

    product = TestProductGivenMessage.new(:amount_field_price => 'x')
    assert !product.valid?
    assert_equal "special message x", product.errors.on(:price)
  end

  test "matches if precision is right" do
    class TestProductValidPrecision < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :precision => 1
    end

    with_locale('de') do 
      [ ',0', '1,0', '1,0'].each do |value|
        assert TestProductValidPrecision.new(:amount_field_price => value).valid?, "expected '#{value}' to be valid"
      end  
    end  
  end
  
  test "explicit definition overwrites default configuration" do
    with_configuration(default = { :separator => '_', :delimiter => ';', :precision => 2 }) do
      class TestProductOverwriteConfiguration < ActiveRecord::Base
        set_table_name 'test_products'
        validates_amount_format_of :price, :separator => '/', :delimiter => '@'
        validates_amount_format_of :stock_price
      end

      [ '/00', '1/00', '12/00', '123/00', '1234/00', '1@234/00', '12@345/00', '123@456/00', '1@234@567/00'
      ].each do |param| 
        param2 = param.gsub('/', '_').gsub('@', ';')
        product = TestProductOverwriteConfiguration.new(:amount_field_price => param, :amount_field_stock_price => param2)
        assert product.valid?, product.errors.full_messages.inspect
        assert_in_delta Float(param.gsub('@', '').sub('/', '.')), product.price, 0.001
      end  
    end
  end
  
  test "nil or blank value is not valid by default" do
    class TestProductNilOrBlankNotValidByDefault < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
      validates_amount_format_of :stock_price
    end
    
    product = TestProductNilOrBlankNotValidByDefault.new(:amount_field_price => nil, :amount_field_stock_price => "")
    assert !product.valid?
    assert_match /format/, product.errors.on(:price)
    assert_match /format/, product.errors.on(:stock_price)
  end

  test "nil or blank value is valid if option :allow_nil or :allow_blank is set to true" do
    class TestProductNilOrBlankValidIfAllowed < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price, :allow_nil => true
      validates_amount_format_of :stock_price, :allow_blank => true
    end
    
    product = TestProductNilOrBlankValidIfAllowed.new(:amount_field_price => nil, :amount_field_stock_price => "")
    assert product.valid?, product.errors.full_messages.inspect
    assert_in_delta 0.0, product.price, 0.001
  end
  
  test "valid format example returns string depending on given configuration" do
    assert_equal "d.ddd,dd", TestProduct.send(:valid_format_example, { :precision => 2, :delimiter => '.', :separator => ',' })
    assert_equal "d,ddd.dd", TestProduct.send(:valid_format_example, { :precision => 2, :delimiter => ',', :separator => '.' })
    assert_equal "dddd,dd", TestProduct.send(:valid_format_example, { :precision => 2, :delimiter => nil, :separator => ',' })
    assert_equal "dddd,d", TestProduct.send(:valid_format_example, { :precision => 1, :delimiter => nil, :separator => ',' })
    assert_equal "dddd", TestProduct.send(:valid_format_example, { :precision => nil, :delimiter => nil, :separator => nil })
    assert_equal "d.ddd", TestProduct.send(:valid_format_example, { :precision => nil, :delimiter => '.', :separator => nil })
  end

  test "default prefix is use for special setter name" do
    class TestProductDefaultPrefix < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    assert TestProductDefaultPrefix.new.respond_to?("#{AmountField::Configuration.prefix}_price=")
  end

  test "configured prefix is use for special setter name" do
    AmountField::Configuration.prefix = 'my_prefix'
    class TestProductConfigPrefix < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :price
    end

    assert TestProductConfigPrefix.new.respond_to?('my_prefix_price=')
    AmountField::Configuration.prefix = 'amount_field'
  end
  
  test "works with float attribute" do
    class TestProductFloatAttribute < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :float_price
    end
    with_locale('de') do
      assert TestProductFloatAttribute.new(:amount_field_float_price => '1.234,00').valid? 
      assert TestProductFloatAttribute.new(:amount_field_float_price => '1234').valid? 
    end  
  end
  
  test "allow separator and delimiter to be optional for german format" do
    class TestProductOptionalSeparatorAndDelimiterForGerman < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :float_price
    end
    with_locale('de') do
      ['1.234,00', '1234,00', '1.234', '1234'].each do |v|
        p = TestProductOptionalSeparatorAndDelimiterForGerman.new(:amount_field_float_price => v)
        assert p.valid?, p.errors.full_messages.inspect
      end 
    end  
  end

  test "allow separator and delimiter to be optional for us format" do
    class TestProductOptionalSeparatorAndDelimiterForUs < ActiveRecord::Base
      set_table_name 'test_products'
      validates_amount_format_of :float_price
    end
    with_locale('en') do
      ['1,234.000', '1234.000', '1,234', '1234'].each do |v|
        p = TestProductOptionalSeparatorAndDelimiterForUs.new(:amount_field_float_price => v)
        assert p.valid?, p.errors.full_messages.inspect
      end 
    end  
  end

  #TODO/2009-08-28/tb do we need :separator => nil, :delimiter => nil ... !?
  
end

