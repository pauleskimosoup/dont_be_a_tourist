class SettingsController < ApplicationController

  layout "admin"
  before_filter :authorize, :except => [:view_image, :image_chooser, :upload_image]
  before_filter :update_current_admin



  def list_admins
    @admins, @admin_pages = Admin.paginate_and_order(params)
    @admins.delete(Admin.tmedia_admin)
  end

  def new_admin
    if request.get?
      @admin = Admin.new
    else
      params[:admin][:feature_ids] ||= []
      @admin = Admin.new(params[:admin])
      @admin.feature_ids = params[:admin][:feature_ids]
      if @admin.save
        flash[:notice] = "The admin was successfully added."
        redirect_to :action => 'list_admins'
      else
        flash[:notice] = "Sorry, there was a problem creating that admin."
        flash[:error_field] = :admin
      end
    end
  end

  def edit_admin
    if request.get?
      @admin = Admin.find(params[:id])
    else
      params[:admin][:feature_ids] ||= []
      @admin = Admin.find(params[:id])
      @admin.feature_ids = params[:admin][:feature_ids]
      if @admin.update_attributes(params[:admin])
        flash[:notice] = "The admin was successfully updated."
        redirect_to :action => 'list_admins'
      else
        flash[:notice] = "Sorry, there was a problem creating that admin."
        flash[:error_field] = :admin
      end
    end
  end

  def delete_admin
    @admin = Admin.find(params[:id])
    if @admin == Admin.find(session[:admin_id])
      @admin.destroy
      flash[:notice] = "The admin has been removed."
      redirect_to :controller => 'login', :action => 'logout'
    else
      @admin.destroy
      flash[:notice] = "The admin has been removed."
      redirect_to :action => 'list_admins'
    end
  end

  def list_backups
    @backups, @backup_pages = Backup.paginate_and_order(params)
  end

  def list_backups_old
    @all_backups = get_backup_list
    @backups, @backup_pages = Pager.pages(@all_backups,
                                                          params[:page] || 1,
                                                          10)
  end

   def get_backup_list
    backups = Backup.find(:all, :order => Backup.order(params))
    current_backups = []
    backups.each do |backup|
      if backup.exists?
        current_backups << backup
      else
        backup.destroy
      end
    end
    current_backups
  end


  def backup
    @backup = Backup.backup
    if @backup
      if @backup.save
        flash[:notice] = "The database was successfully backed up."
      else
        flash[:notice] = "Sorry, there was a problem backing up the database."
      end
    else
      flash[:notice] = "Sorry, there was a problem backing up the database."
    end
    redirect_to :action => 'list_backups'
  end

  def restore_backup

    db_name = ActiveRecord::Base.configurations['development']['database']
    db_user = ActiveRecord::Base.configurations['development']['username']
    db_pass = ActiveRecord::Base.configurations['development']['password']

    @backup = Backup.find(params[:id])
    @old_backups = Backup.find(:all)
    @new_backups = []
    for old_backup in @old_backups
      new_backup = Backup.new
      for col in Backup.content_columns
        new_backup[col.name] = old_backup[col.name]
        new_backup.dont_time_stamp_me = true
      end
      @new_backups << new_backup
    end
    if @backup.exists?
      Dir.chdir(RAILS_ROOT) do
        str = "mysql #{db_name} -u #{db_user} -p#{db_pass} < '#{@backup.filename}'"
        # raise str
        if system(str)
          restored_backups = Backup.find(:all)
          for backup in restored_backups
            backup.destroy
          end
          for backup in @new_backups
            backup.save
          end
          flash[:notice] = "The database has been successfully restored."
        else
          flash[:notice] = "Sorry, there was a problem restoring that data."
        end
      end
    else
      flash[:notice] = "Sorry, that backup file no longer exists."
      @backup.destroy
    end
    redirect_to :action => 'list_backups'
  end

  def delete_backup
    @backup = Backup.find(params[:id])
    File.delete(@backup.filename)
    @backup.destroy
    flash[:notice] = "The backup has been successfully deleted."
    redirect_to :action => 'list_backups'
  end

  def site_profile_form
    [{:type => :text_area, :variable => :site_profile, :attribute => :address, :label => "Address", :options => {:class => "summary"}},
     {:type => :text_field, :variable => :site_profile, :attribute => :phone_number, :label => "Phone Number"},
     {:type => :text_field, :variable => :site_profile, :attribute => :fax_number, :label => "Fax Number"},
     {:type => :text_field, :variable => :site_profile, :attribute => :email, :label => "Email"}]
  end

  def edit_details
    @site_profile = SiteProfile.find(:first)
    if request.post?
      if @site_profile.update_attributes(params[:site_profile])
        flash[:notice] = "Your contact details have been successfully updated."
      else
        flash[:notice] = "Sorry. There was a problem updating your contact details."
      end
    end
  end

  #this is the page that opens in a popup when adding an image to a story
  def image_chooser
    if params[:tag] and params[:tag] != "All"
      @all_pictures = Picture.all_tagged(params[:tag])
    else
      @all_pictures = Picture.find(:all)
    end
    pictures, @picture_pages = Pager.pages(@all_pictures, params[:page] || 1, 20)
    # these two lines split the pictures array into three columns.
    i = -1
    @rows = pictures.inject([[], [], [], [], []]){|memo, pic| i += 1; memo[i%5] << pic; memo}
    @field_prefix = params[:field]
    render :layout => false
  end

  # this is the page that 'image_chooser' posts to when they add a new image
  def upload_image
    @picture = Picture.process_comprehensive_image_field(params[:image], params[:tag])
    @picture.save
    @field_prefix = params[:field_prefix]
    render :layout => false
  end

  def picture_form
    [{:type => :file_field, :variable => :image, :attribute => :image_data, :label => "Image File"},
     {:type => :text_field, :variable => :image, :attribute => :image_alt, :label => "Image Title"},
     {:type => :select_tag, :variable => :tag, :select_options => Picture.all_tags, :label => "Category"}]
  end

  def list_images
    @all_pictures = Picture.find(:all, :order => "last_updated desc")
    @pictures, @picture_pages = Pager.pages(@all_pictures, params[:page] || 1, 10)
  end

  def new_image
    @picture = Picture.new
    @picture_form = picture_form
    if request.post?
      @picture = Picture.process_comprehensive_image_field(params[:image], params[:tag])
      @picture.save
      redirect_to :action => 'list_images'
    end
  end

  def edit_form
    [{:type => :text_field, :variable => :picture, :attribute => :image_alt, :label => "Image Title"},
     {:type => :select_tag, :variable => :tag, :select_options => Picture.all_tags, :selected => @picture.tags, :label => "Category"}]
  end

  def edit_image
    @picture = Picture.find(params[:id])
    @edit_form = edit_form
    if request.post?
      @picture.tags = params[:tag]
      @picture.image_alt = params[:picture][:image_alt]
      @picture.save
      redirect_to :action => 'list_images'
    end
  end

  def view_image
    @picture = Picture.find(params[:id])
    render :layout => false
  end

  def image_url
    @url = "/images/gallery/" + Picture.find(params[:id]).resize(66)
    render :layout => false
  end

  def delete_image
    picture = Picture.find(params[:id]).destroy
    redirect_to :action => 'list_images'
  end

end
