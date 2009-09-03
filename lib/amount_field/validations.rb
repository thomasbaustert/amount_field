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

            # in case there is no assignment via 'amount_field_XXX=' method, we don't need to validate.
            next unless raw_value.kind_of?(AssignedValue)

            converted_value = raw_value.convert(format_configuration(configuration))
            original_value  = raw_value.original_value

            # in case nil or blank is allowed, we don't validate
            next if configuration[:allow_nil] and original_value.nil?
            next if configuration[:allow_blank] and original_value.blank?

            if valid_format?(original_value, format_configuration(configuration))
              # assign converted value to attribute so other validations macro can work on it 
              # and the getter returns a value
              record.send("#{attr_name}=", converted_value)
            else  
              # assign original value as AssignedValue so multiple calls of this validation will
              # consider the value still as invalid.
              record.send("#{attr_name}=", raw_value)
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
                def #{AmountField::Configuration.prefix}_#{attr_name}=(value)
                  self[:#{attr_name}] = AssignedValue.new(value)
                end
              EOV
            end
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
      
      # Stores the original assigned value and provide convertion depending on actual configuration.
      class AssignedValue #:nodoc:
        attr_accessor :converted_value, :original_value

        def initialize(original_value)
          @original_value = original_value
        end
        
        def convert(configuration)
          @converted_value = original_value.to_s.gsub(configuration[:delimiter].to_s, '')
          @converted_value = @converted_value.sub(configuration[:separator].to_s, '.') unless configuration[:separator].blank?
          @converted_value
        end

        # In case of an error, xxx_before_type_cast returns an instance of this class and to_d
        # is called on that during type_cast. So we need to define this method and we return 
        # <tt>nil</tt> because the format is invalid and therefore there is no value.
        # See ActiveRecord::ConnectionAdapters::Column#type_cast
        def to_d
          nil
        end
            
        # In case the attribute is of type Float an the format validation fails, xxx_before_type_cast 
        # returns an instance of this class and to_f is called on that during type_cast. So we need
        # to define this method we return <tt>nil</tt> because the format is invalid and therefore 
        # there is no value.
        # See ActiveRecord::ConnectionAdapters::Column#type_cast
        def to_f
          nil
        end
      end
      
    end
  end
end
