module CartHelper

  def self.current_cart
    cart = Cart.find_by_user_id(session[:user_id]) || nil
  end

end
