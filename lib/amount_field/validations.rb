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
          # called only once
          configuration = attr_names.extract_options!

          define_special_setter(attr_names, configuration)

          # defines the callbacks methods that are called on validation
          validates_each(attr_names, configuration) do |record, attr_name, value|
            raw_value = record.send("#{attr_name}_before_type_cast") || value

            # we have to read the configuration every time to get the current I18n value
            format_configuration = { :precision => I18n.t('number.format.precision'), 
                                     :delimiter => I18n.t('number.format.delimiter'), 
                                     :separator => I18n.t('number.format.separator') }.dup
            # update it with a maybe given default configuration                         
            format_configuration.update(AmountField::ActiveRecord::Validations.configuration)
            # update it with a maybe given explicit configuration via the macro                         
            format_configuration.update(configuration)

            # in case there is no assignment via 'amount_field_XXX=' method, we don't need to validate.
            next unless raw_value.kind_of?(AssignedValue)

            converted_value = raw_value.convert(format_configuration)
            original_value  = raw_value.original_value

            # in case nil or blank is allowed, we don't validate
            next if configuration[:allow_nil] and original_value.nil?
            next if configuration[:allow_blank] and original_value.blank?

            if valid_format?(original_value, format_configuration)
              # assign converted value to attribute so other validations macro can work on it 
              # and the getter returns a value
              record.send("#{attr_name}=", converted_value)
            else  
              # assign original value to attribute so other validations macro can work on it two.
              record.send("#{attr_name}=", original_value)
              record.errors.add(attr_name, :invalid_amount_format, :value => original_value, 
                :default => configuration[:message], :format_example => valid_format_example(format_configuration))
            end  

          end
        end
        
        private

          # Stores the original assigned value and provide convertion depending on actual configuration.
          class AssignedValue
            attr_accessor :converted_value, :original_value

            def initialize(original_value)
              @original_value = original_value
            end
            
            def convert(configuration)
              @converted_value = original_value.to_s.gsub(configuration[:delimiter].to_s, '')
              @converted_value = @converted_value.sub(configuration[:separator].to_s, '.') unless configuration[:separator].blank?
              @converted_value
            end

            def to_f # needed for AR::type_cast
              @original_value
            end
          end

          def define_special_setter(attr_names, configuration)
            attr_names.each do |attr_name| 
              class_eval <<-EOV
                def #{AmountField::Configuration.prefix}_#{attr_name}=(value)
                  self[:#{attr_name}] = AssignedValue.new(value)
                end
              EOV
            end
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
