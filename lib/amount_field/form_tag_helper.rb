module AmountField #:nodoc:
  module Helpers #:nodoc:
    module FormTagHelper
      include ActionView::Helpers::NumberHelper

      def amount_field_tag(name, value = nil, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})
  
        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        options[:value] ||= number_with_precision(value.to_s, format_options)
        options[:name]  = "#{AmountField::Configuration.prefix}_#{name}"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"

        text_field_tag(name, value, options)
      end
    
    end
  end
end
