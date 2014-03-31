class Spree::WishedProductsController < Spree::StoreController
  respond_to :html

  def create
    @wished_product = Spree::WishedProduct.new(params[:wished_product])
    @wishlist = spree_current_user.wishlist

    if @wishlist.include? @wished_product.variant_id
      @wished_product = @wishlist.wished_products.detect {|wp| wp.variant_id == @wished_product.variant_id }
    else
      @wished_product.wishlist = @wishlist
      @wished_product.save
    end

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wishlist) }
    end
  end

  def update
    @wished_product = Spree::WishedProduct.find(params[:id])
    @wished_product.update_attributes(params[:wished_product])

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wished_product.wishlist) }
    end
  end

  def destroy
    @wished_product = Spree::WishedProduct.find(params[:id])
    @wished_product.destroy

    respond_with(@wished_product) do |format|
      format.html { redirect_to wishlist_url(@wished_product.wishlist) }
    end
  end

end
