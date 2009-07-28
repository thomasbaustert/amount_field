module AmountField #:nodoc:
  module Helpers #:nodoc:
    module FormHelper #:nodoc:

      include ActionView::Helpers::NumberHelper

      def amount_field(method, options = {})
        format_options = AmountField::ActiveRecord::Validations.configuration
        format_options.merge!(options.delete(:format) || {})
    
        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # XXX_before_typecast value provided by rails (the original value inserted by the user).
        options[:value] ||= number_with_precision(object.send(method), format_options) unless object.errors.on(method)
        options[:name]  = "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"

        text_field(method, options)
      end

    end
  end
end

