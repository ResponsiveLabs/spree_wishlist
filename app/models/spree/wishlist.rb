class Spree::Wishlist < ActiveRecord::Base
  belongs_to :user, :class_name => Spree.user_class 
  has_many :wished_products
  before_create :set_access_hash

  attr_accessible :name, :is_default, :is_private, :user, :type_of_delivery
    
  validates :name, :presence => true
  
  attr_accessible :name, :is_default, :is_private

  def include?(variant_id)
    self.wished_products.map(&:variant_id).include? variant_id.to_i
  end

  def to_param
    self.access_hash
  end

  def self.get_by_param(param)
    Spree::Wishlist.find_by_access_hash(param)
  end

  def can_be_read_by?(user)
    !self.is_private? || user == self.user
  end

  def is_default=(value)
    self['is_default'] = value
    if self.is_default?
      Spree::Wishlist.update_all({:is_default => false}, ["id != ? AND is_default = ? AND user_id = ?", self.id, true, self.user_id])
    end
  end

  def is_public?
    !self.is_private?
  end

  def update_quantities(order)
    wished_products_in_order(order).each do |line_item, wished_product|
      Spree::PurchasedProduct.create quantity: [wished_product.quantity, line_item.quantity].min,
                                     item_price: line_item.price,
                                     user: order.user,
                                     wished_product: wished_product,
                                     order: order

      wished_product.update_attributes quantity: [wished_product.quantity - line_item.quantity, 0].max
    end
  end


  private

  def set_access_hash
    random_string = SecureRandom::hex(16)
    self.access_hash = Digest::SHA1.hexdigest("--#{user_id}--#{random_string}--#{Time.now}--")
  end

  def wished_products_in_order(order)
    common_variant_ids = common_variant_ids_with order

    line_items = order.line_items.where(variant_id: common_variant_ids).sort_by { |p| p.variant_id }
    wished_products = self.wished_products.where(variant_id: common_variant_ids).sort_by { |p| p.variant_id }

    line_items.zip wished_products
  end

  def common_variant_ids_with(order)
    order.line_items.pluck(:variant_id) & self.wished_products.pluck(:variant_id)
  end

end
