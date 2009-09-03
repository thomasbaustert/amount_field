module ActionView #:nodoc:
  module Helpers #:nodoc:
    module FormTagHelper
      include ActionView::Helpers::NumberHelper

      def amount_field_tag(object, method, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})
  
        object      = instance_variable_get("@#{object}") if object.is_a?(Symbol)
        object_name = object.class.name.underscore
    
        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        unless object.errors.on(method)
          options[:value] ||= number_with_precision(object.send(method), format_options)
        else
          options[:value] ||= object.send("#{method}_before_type_cast").original_value
        end
        
        options[:name]  = "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"

        text_field_tag(object, method, options)
      end
    
    end
  end
end
