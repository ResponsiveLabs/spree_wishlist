Spree::OrdersController.class_eval do

  def empty
    if @order = current_order
      @order.empty!
      session[:wishlist] = nil
    end

    redirect_to spree.cart_path
  end

end
