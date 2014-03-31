class Spree::PurchasedProduct < ActiveRecord::Base
  belongs_to :user
  belongs_to :wished_product
  belongs_to :order

  attr_accessible :item_price, :quantity, :user, :wished_product, :order
end
