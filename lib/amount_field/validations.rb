module AmountField #:nodoc:
  module ActiveRecord #:nodoc: 
    module Validations

      @@configuration = {}
      mattr_accessor :configuration

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        
        def validates_amount_format_of(*attr_names)
          # code before validates_each is called only once!
          configuration = attr_names.extract_options!

          define_special_setter(attr_names, configuration)

          # the following code defines the callbacks methods that are called on every validation
          validates_each(attr_names, configuration) do |record, attr_name, value|
            # in case there is no assignment via 'amount_field_XXX=' method, we don't need to validate.
            next unless record.instance_variable_defined?("@#{special_method_name(attr_name)}")

            # get the original assigned value first to always run the validation for this value!
            # if we us 'before_type_cast' here, we would get the converted value and not the 
            # original value if we call the validation twice.
            original_value = record.instance_variable_get("@#{special_method_name(attr_name)}")
            original_value ||= record.send("#{attr_name}_before_type_cast") || value

            # in case nil or blank is allowed, we don't validate
            next if configuration[:allow_nil] and original_value.nil?
            next if configuration[:allow_blank] and original_value.blank?

            converted_value = convert(original_value, format_configuration(configuration))

            if valid_format?(original_value, format_configuration(configuration))
              # assign converted value to attribute so other validations macro can work on it 
              # and the getter returns a value
              record.send("#{attr_name}=", converted_value)
            else  
              # assign original value as AssignedValue so multiple calls of this validation will
              # consider the value still as invalid.
              record.send("#{attr_name}=", original_value)
              record.errors.add(attr_name, :invalid_amount_format, :value => original_value, 
                :default => configuration[:message], 
                :format_example => valid_format_example(format_configuration(configuration)))
            end  

          end
        end
        
        private

          def define_special_setter(attr_names, configuration)
            attr_names.each do |attr_name| 
              class_eval <<-EOV
                def #{special_method_name(attr_name)}=(value)
                  @#{special_method_name(attr_name)} = value
                  self[:#{attr_name}] = value
                end
                
                def #{special_method_name(attr_name)}  
                  @#{special_method_name(attr_name)}
                end
              EOV
            end
          end
          
          def special_method_name(attr_name)
            "#{AmountField::Configuration.prefix}_#{attr_name}"
          end

          def convert(original_value, configuration)
            converted_value = original_value.to_s.gsub(configuration[:delimiter].to_s, '')
            converted_value = converted_value.sub(configuration[:separator].to_s, '.') unless configuration[:separator].blank?
            converted_value
          end
          
          # we have to read the configuration every time to get the current I18n value
          def format_configuration(configuration)
            format_options = I18n.t(:'number.amount_field.format', :raise => true) rescue {}
            # update it with a maybe given default configuration                         
            format_options = format_options.merge(AmountField::ActiveRecord::Validations.configuration)
            # update it with a maybe given explicit configuration via the macro                         
            format_options.update(configuration)
          end

          def valid_format?(value, configuration)
            return false if !value.kind_of?(String) || value.blank?

            # add ,00 to 1234 
            if !value.include?(configuration[:separator].to_s) && !configuration[:separator].blank?
              value = "#{value}#{configuration[:separator]}#{'0' * configuration[:precision].to_i}"
            end   

            cs = configuration[:separator]
            cd = "\\#{configuration[:delimiter]}"
            cp = configuration[:precision]

            # (1234 | 123.456),00 
            !(value =~ /\A[-\+]{0,1}((\d*)|(\d{0,3}(#{cd}\d{3})*))#{cs}\d{0,#{cp}}\z/).nil?
          end
          
          def valid_format_example(configuration)
            s = 'd'
            s << "#{configuration[:delimiter]}" unless configuration[:delimiter].nil?
            s << "ddd"
            s << "#{configuration[:separator]}" unless configuration[:separator].nil?
            s << "#{'d' * configuration[:precision].to_i}" unless configuration[:precision].nil?
            s
          end

      end
      
    end
  end
end
