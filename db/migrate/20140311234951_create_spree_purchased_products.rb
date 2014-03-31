class CreateSpreePurchasedProducts < ActiveRecord::Migration
  def change
    create_table :spree_purchased_products do |t|
      t.integer :quantity
      t.decimal :item_price,  precision: 8, scale: 2
      t.references :user
      t.references :wished_product
      t.references :order

      t.timestamps
    end

    add_index :spree_purchased_products, :wished_product_id
    add_index :spree_purchased_products, :order_id
  end
end
