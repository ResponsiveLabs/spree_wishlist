Spree::ProductsController.class_eval do

  def show
    return unless @product

    @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])
    @product_properties = @product.product_properties.includes(:property)
   
    if request.env['HTTP_REFERER']
      wishlist_url = URI.parse(request.env['HTTP_REFERER']).path
      if wishlist_url.include? 'wishlists'
        wishlist_token = wishlist_url.gsub!('/wishlists/','')
        session[:wishlist] = wishlist_token
      end
      unless session[:wishlist].nil?
        flash.notice = Spree::Wishlist.find_by_access_hash(session[:wishlist]).name
      end
    end
    
    referer = request.env['HTTP_REFERER']
    if referer
      begin
        referer_path = URI.parse(request.env['HTTP_REFERER']).path
        # Fix for #2249
      rescue URI::InvalidURIError
        # Do nothing
      else
        if referer_path && referer_path.match(/\/t\/(.*)/)
          @taxon = Spree::Taxon.find_by_permalink($1)
        end
      end
    end
  end
end
