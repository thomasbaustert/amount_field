class TestProduct < ActiveRecord::Base

  validates_amount_format_of :price
  validates_numericality_of :price, :message => "not numericality"
  validates_presence_of :price

end
