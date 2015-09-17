class OfferSettingAdminController < ApplicationController

  layout "admin"
  before_filter :authorize
  before_filter :update_current_admin

  def index
    redirect_to :action => 'edit'
  end

  def edit
    @offer_setting = OfferSetting.instance
    if request.post?
      if @offer_setting.update_attributes(params[:offer_setting])
        flash[:notice] = "The offer settings were successfully updated."
      else
        flash[:notice] = "Sorry, there was a problem updating the offer settings."
        flash[:error_field] = :user
      end
    end
  end

end 
