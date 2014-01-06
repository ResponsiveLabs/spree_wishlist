class AddQuantityToWishedProducts < ActiveRecord::Migration
  def change
    add_column :spree_wished_products, :quantity, :integer
  end
end
