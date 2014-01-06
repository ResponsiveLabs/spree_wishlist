Spree::CheckoutController.class_eval do
  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')

      unless @order.next
        flash[:error] = @order.errors.full_messages.join("\n")
        redirect_to checkout_state_path(@order.state) and return
      end

      if @order.completed?
        session[:order_id] = nil
        unless session[:wishlist].nil?
          wishlist = Spree::Wishlist.find_by_access_hash(session[:wishlist])
          ids = @order.line_items.pluck(:variant_id)
          wished_products = wishlist.wished_products.select {|wp| ids.include?(wp.variant_id)}
          
          wished_products.each do |wishp|
            product = @order.line_items.where(:variant_id => wishp.variant_id)
            if product.quantity <= wishp.quantity 
              wishp.update_attributes(:quantity => wishp.quantity - product.quantity)
            end
          end
          session[:wishlist] = nil
        end
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = "nothing special"
        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end

end
