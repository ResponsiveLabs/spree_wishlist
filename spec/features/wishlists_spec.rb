require 'spec_helper'
describe "Checkout", :js => true do

  let(:second_user) {
    Spree::User.create({
      "email"                 => "roberto@example.com",
      "password"              => "roberto123",
      "password_confirmation" => "roberto123"
    }) }
 
  let!(:country) { create(:country, :name => "United States", :states_required => true) }
  let!(:state) { create(:state, :name => "Alabama", :country => country) }
  let!(:zone) { create(:zone) }
  let(:order) { OrderWalkthrough.up_to(:complete) }
  let!(:stock_location) { create(:stock_location) }
  let!(:payment_method) { create(:payment_method) }
  let!(:shipping_method) do
    shipping_method = create(:shipping_method)
    calculator = Spree::Calculator::Shipping::PerItem.create!({:calculable => shipping_method, :preferred_amount => 10}, :without_protection => true)
    shipping_method.calculator = calculator
    shipping_method.tap(&:save)
  end
  let!(:address) { create(:address, :state => state, :country => country) }
  
  context "product detail" do
    
    it "can display wishlist name" do
      user = FactoryGirl.create(:user)
      sign_in_as!(user)
      
      wishlist = Spree::Wishlist.create({"name" => "SpreeWishlist", "is_private" => false,
                              "is_default" => false, "user" => second_user})
      
      prod = FactoryGirl.create(:product)
      variant2 = FactoryGirl.create(:variant)
      variant2.product = prod
      variant2.save
      
      wished_product = Spree::WishedProduct.create(:variant_id => variant2.id, :quantity => 2, :wishlist_id => wishlist.id)
      visit "/wishlists/#{wishlist.access_hash}"
      click_link prod.name
      page.should have_content("SpreeWishlist")
    end

    it "can purchase this product" do
      user = FactoryGirl.create(:user)
      sign_in_as!(user)
      wishlist = Spree::Wishlist.create({"name" => "SpreeWishlist", "is_private" => false,
                              "is_default" => false, "user" => second_user})
      prod = FactoryGirl.create(:product)
      variant2 = FactoryGirl.create(:variant)
      variant2.product = prod
      variant2.save
      wished_product = Spree::WishedProduct.create(:variant_id => variant2.id, :quantity => 2, :wishlist_id => wishlist.id)
      prod.shipping_category = shipping_method.shipping_categories.first
      prod.save!
    

      visit "/wishlists/#{wishlist.access_hash}"
      click_link prod.name
      click_button "Add To Cart"
      within(".cart-item-description") do
        page.should have_content(prod.name)
      end
    end
  end


  context "order completed" do
    let(:credit_cart_payment) {create(:bogus_payment_method, :environment => 'test') }
    let(:check_payment) {create(:payment_method, :environment => 'test') }
    
    before do
      Spree::Order.any_instance.stub :has_available_payment => true
      Spree::Order.any_instance.stub :payment_required? => false
    end
    
    it "full checkout"do
      user = Spree::User.create("email" => "foo@bar.com", "password" => "foobar123", "password_confirmation" => "foobar123")
      sign_in_as!(user)
      wishlist = Spree::Wishlist.create({"name" => "SpreeWishlist", "is_private" => false,
                                         "is_default" => false, "user" => second_user})
      prod = FactoryGirl.create(:product)
      prod.master.stock_items.first.update_column(:count_on_hand, 1)
      variant2 = FactoryGirl.create(:variant)
      variant2.product = prod
      variant2.save
      prod.shipping_category = shipping_method.shipping_categories.first
      prod.save!
      wished_product = Spree::WishedProduct.create(:variant_id => prod.master.id, :quantity => 2, :wishlist_id => wishlist.id)
      visit "/wishlists/#{wishlist.access_hash}"
      click_link prod.name
      click_button "Add To Cart"
      click_button "Checkout"
      #fill_in_address
      str_addr = "bill_address"
      select "United States", :from => "order_#{str_addr}_attributes_country_id"
      ['firstname', 'lastname', 'address1', 'city', 'zipcode', 'phone'].each do |field|
        fill_in "order_#{str_addr}_attributes_#{field}", :with => "#{address.send(field)}"
      end
      select "#{address.state.name}", :from => "order_#{str_addr}_attributes_state_id"
      check "order_use_billing"
      click_button "Save and Continue"
      click_button "Save and Continue"
      page.should have_content("Your order has been processed successfully")
      order = Spree::Order.first
      order.user.should == user
      #order.line_items.first.variant.id.should == wished_product.variant.id
    end
  end

end
