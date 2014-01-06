class AddTypeOfDeliveryToWishlists < ActiveRecord::Migration
  def change
    add_column :spree_wishlists, :type_of_delivery, :string
  end
end
