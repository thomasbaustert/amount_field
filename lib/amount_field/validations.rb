module AmountField #:nodoc:
  module ActiveRecord #:nodoc: 
    module Validations

      DEFAULT_CONFIGURATION_DE = { :precision => 2, :delimiter => '.', :separator => ',' }
      DEFAULT_CONFIGURATION_US = { :precision => 2, :delimiter => ',', :separator => '.' }
      @@configuration = DEFAULT_CONFIGURATION_DE
      mattr_accessor :configuration

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods
        
        def validates_amount_format_of(*attr_names)
          # called only once

          configuration = AmountField::ActiveRecord::Validations::DEFAULT_CONFIGURATION_DE.dup
          configuration.update(AmountField::ActiveRecord::Validations.configuration)
          configuration.update(attr_names.extract_options!)

          define_special_setter(attr_names, configuration)

          # defines the callbacks methods that are called on validation
          validates_each(attr_names, configuration) do |record, attr_name, value|
            raw_value = record.send("#{attr_name}_before_type_cast") || value

            # in case there is no assignment via 'amount_field_XXX=' method, we don't need to validate.
            next unless raw_value.kind_of?(Array)

            converted_value, original_value = raw_value

            # in case nil or blank is allowed, we don't validate
            next if configuration[:allow_nil] and original_value.nil?
            next if configuration[:allow_blank] and original_value.blank?

            if valid_format?(original_value, configuration)
              # assign converted value to attribute so other validations macro can work on it 
              # and the getter returns a value
              record.send("#{attr_name}=", converted_value)
            else  
              # assign original value to attribute so other validations macro can work on it two.
              record.send("#{attr_name}=", original_value)
              record.errors.add(attr_name, :invalid_amount_format, :value => original_value, 
                :default => configuration[:message], :format_example => valid_format_example(configuration))
            end  

          end
        end
        
        private

          def define_special_setter(attr_names, configuration)
            attr_names.each do |attr_name| 
              class_eval <<-EOV
                def #{AmountField::Configuration.prefix}_#{attr_name}=(value)
                  converted_value = value.to_s.gsub('#{configuration[:delimiter]}', '')
                  converted_value = converted_value.sub('#{configuration[:separator]}', '.') unless #{configuration[:separator].blank?}
                  self[:#{attr_name}] = [converted_value, value]
                end
              EOV
            end
          end

          def valid_format?(value, configuration)
            return false if !value.kind_of?(String) || value.blank?
            
            cs = configuration[:separator]
            cd = "\\#{configuration[:delimiter]}"
            cp = configuration[:precision]

            # (1234 | 123.456),00 
            !(value =~ /\A((\d*)|(\d{0,3}(#{cd}\d{3})*))#{cs}\d{#{cp}}\z/).nil?
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
