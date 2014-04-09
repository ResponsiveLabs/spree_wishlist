Spree::CheckoutController.class_eval do
  before_filter :set_wishlist_address, only: :edit

  def update
    if @order.update_attributes(object_params)
      fire_event('spree.checkout.update')

      unless @order.next
        flash[:error] = @order.errors.full_messages.join('\n')
        redirect_to checkout_state_path(@order.state) and return
      end

      if @order.completed?
        if session[:wishlist]
          wishlist = Spree::Wishlist.find_by_access_hash(session[:wishlist])
          wishlist.update_quantities(@order) if wishlist

          session[:wishlist] = nil
        end

        session[:order_id] = nil
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:commerce_tracking] = 'nothing special'

        redirect_to completion_route
      else
        redirect_to checkout_state_path(@order.state)
      end
    else
      render :edit
    end
  end

  protected

  def set_wishlist_address
    if @order && @order.state == 'address' && session[:wishlist]
      @wishlist_address = Spree::Wishlist.find_by_access_hash(session[:wishlist]).try :ship_address
    end
  end
end
