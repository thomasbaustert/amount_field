module ActionView #:nodoc:
  module Helpers #:nodoc:
    module FormTagHelper
      include ActionView::Helpers::NumberHelper

      def amount_field_tag(object, method, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})
  
        instance = instance_variable_get("@#{object}") if object.is_a?(Symbol)
        object_name = instance.class.name.underscore
    
        options[:value] ||= number_with_precision(instance.send(method), format_options)
        options[:name]  = "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"

        text_field_tag(object, method, options)
      end
    
    end
  end
end
