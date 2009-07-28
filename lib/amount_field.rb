# AmountField

require 'amount_field/validations'
require 'amount_field/form_helper'
require 'amount_field/form_tag_helper'

ActiveRecord::Base.class_eval do
  include AmountField::ActiveRecord::Validations
end

ActionView::Helpers::FormBuilder.class_eval do
  include AmountField::Helpers::FormHelper
end

ActionView::Helpers::FormHelper.class_eval do
  include AmountField::Helpers::FormHelper
end

I18n.load_path << "#{File.dirname(__FILE__)}/../locale/en.yml"
I18n.load_path << "#{File.dirname(__FILE__)}/../locale/de.yml"

