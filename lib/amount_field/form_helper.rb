module AmountField #:nodoc:
  module Helpers #:nodoc:

    module FormHelper #:nodoc:

      include ActionView::Helpers::NumberHelper

      def amount_field(object_name, method, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})

        object = options.delete(:object) || instance_variable_get("@#{object_name}")

        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        unless object.errors.on(method)
          options[:value] ||= number_with_precision(object.send(method), format_options)
        else
          options[:value] ||= object.send("#{method}_before_type_cast")
        end

        options[:name]  ||= "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"
        options[:id]    ||= "#{object_name}_#{method}"

        text_field(object_name, method, options)
      end

    end

    module FormBuilder #:nodoc:

      include ActionView::Helpers::NumberHelper

      def amount_field(method, options = {})
        #todo try to remove redundant code by using: @template.amount_field(object, method, options)
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})

        if (explicit_object = options.delete(:object))
          self.object = explicit_object
        end
            
        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        unless object.errors.on(method)
          options[:value] ||= number_with_precision(object.send(method), format_options)
        else
          options[:value] ||= object.send("#{method}_before_type_cast")
        end

        options[:name]  ||= "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"
        options[:id]    ||= "#{object_name}_#{method}"
        
        text_field(method, options)
      end

    end

  end
end

