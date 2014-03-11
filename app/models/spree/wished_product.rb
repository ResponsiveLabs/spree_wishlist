class Spree::WishedProduct < ActiveRecord::Base
  belongs_to :variant
  belongs_to :wishlist
  
  attr_accessible :wishlist_id, :variant, :variant_id, :quantity, :initial_quantity

  before_create :set_default_values

  private

  def set_default_values
    self.quantity = 1 unless quantity
    self.initial_quantity = quantity
  end
end
