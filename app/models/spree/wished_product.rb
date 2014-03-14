class Spree::WishedProduct < ActiveRecord::Base
  belongs_to :variant
  belongs_to :wishlist
  has_many   :purchased_products
  
  attr_accessible :wishlist_id, :variant, :variant_id, :quantity, :initial_quantity

  before_save :update_quantity

  private

  def update_quantity
    self.initial_quantity ||= 1
    self.quantity = [initial_quantity - purchased_products.sum(:quantity), 0].max
  end
end
