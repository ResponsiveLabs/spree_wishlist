class AddInitialQuantityToSpreeWishedProducts < ActiveRecord::Migration
  def change
    add_column :spree_wished_products, :initial_quantity, :integer
  end
end
