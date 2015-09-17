class ProductAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'list'
  end
  
  def list
    @list_name = :product_admin_list
    update_session
    @products, @product_pages = Product.paginate_and_order(session[@list_name])
  end

  def update_session
    unless session[@list_name]
      session[@list_name] = {}
    end
    [:page, :order_direction, :order_field, :search].each do |param|
      if params[param]
        session[@list_name][param] = params[param]
      end
    end
  end


  def new
    if request.get?
      @product = Product.new
    else
      @product = Product.new(params[:product])
      if @product.save
        flash[:notice] = "The extra was successfully added."
        redirect_to :action => 'list'
      else
        flash[:notice] = "Sorry, there was a problem creating that extra."
        flash[:error_field] = :product
      end
    end
  end

  def edit
    @product = Product.find(params[:id])
    if request.post?
      if @product.update_attributes(params[:product])
        flash[:notice] = "The extra was successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem creating that extra."
        flash[:error_field] = :product
      end
    end
  end

  def delete
    @product = Product.find(params[:id])
    if @product.destroy
      flash[:notice] = "That extra was succesfully deleted."
    else
      flash[:notice] = "There was a problem deleting that extra."
    end
    redirect_to :action => 'list'
  end


end
