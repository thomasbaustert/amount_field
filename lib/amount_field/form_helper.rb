module AmountField #:nodoc:
  module Helpers #:nodoc:

    #TODO/2010-04-23/tb remove redundant code
    # using @template.amount_field(object, method, options) !?
    
    module FormHelper

      include ActionView::Helpers::NumberHelper

      def amount_field(object_name, method, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})
        
        object = options.delete(:object) || instance_variable_get("@#{object_name}")

        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        if object.errors[method].blank?
          options[:value] ||= number_with_precision(object.send(method), format_options)
        else
          options[:value] ||= object.send("#{AmountField::Configuration.prefix}_#{method}") || object.send("#{method}_before_type_cast")
        end

        options[:name]  ||= "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"
        options[:id]    ||= "#{object_name}_#{method}"

        text_field(object_name, method, options)
      end

    end

    module FormBuilder

      include ActionView::Helpers::NumberHelper

      def amount_field(method, options = {})
        format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
        format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
        format_options.merge!(options.delete(:format) || {})

        if (explicit_object = options.delete(:object))
          self.object = explicit_object
        end

        # if no explicit value is given, we set a formatted one. In case of an error we take the
        # original value inserted by the user.
        if object.errors[method].blank?
          options[:value] ||= number_with_precision(object.send(method), format_options)
        else
          options[:value] ||= object.send("#{AmountField::Configuration.prefix}_#{method}") || object.send("#{method}_before_type_cast")
        end

        # Note: we don't set options[:id] here, because caller or Rails knows best what to do.
        # We accidentally set it to "foo[bar]_name" instead of "foo_bar_name".
        options[:name]  ||= "#{object_name}[#{AmountField::Configuration.prefix}_#{method}]"
        options[:class] = "#{options[:class]} #{AmountField::Configuration.css_class}"
        
        text_field(method, options)
      end

    end

  end
end

