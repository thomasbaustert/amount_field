module AmountField
  class Configuration

    ##
    # Defines the prefix for the special setter method name: 
    #   def #{prefix}_xxx=(value) ...
    #   end
    #
    @@prefix = 'amount_field'
    mattr_accessor :prefix

    ##
    # Defines the CSS class name for the <tt>amount_field</tt> helper.
    #   <input ...class="... #{css_class}" .../>
    #
    @@css_class = 'amount_field'
    mattr_accessor :css_class
    
  end
end