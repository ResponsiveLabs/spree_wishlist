class AddShipAddressToSpreeWishlists < ActiveRecord::Migration
  def change
    add_column :spree_wishlists, :ship_address_id, :integer
  end
end
