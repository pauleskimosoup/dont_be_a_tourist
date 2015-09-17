# encoding: UTF-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def hide_right
    @hide_right = true
  end

  def hide_right?
    @hide_right
  end

  def hide_basket_expire
    @hide_basket_expire = true
  end

  def hide_basket_expire?
    @hide_basket_expire
  end

  ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
     "#{html_tag}"
  end

  def price(value)
    "£#{sprintf('%.2f', value.to_f)}"
  end

  def paypal_extra(price)
    # to change this the cart total calculation method needs to change too
    # and the paypal send off method
    (price*0.035)
  end

  def paging(pager)
    ret = ""
    if pager.count != 0
      ret << "<div class=\"pagecount\">"
      # ret << pager.range.to_s << " of " << pager.count.to_s << "|"
      if pager.previous_page
        if pager.page > 5
          start_page = pager.page-5
        else
          start_page = 1
        end
        ret << link_with_params('|&lt;First', :page => 1)
        ret << " "
        ret << link_with_params('&lt;&lt;Back', :page => pager.previous_page)
        (start_page..(pager.page-1)).each do |pi|
          ret << ' ' << link_with_params("#{pi}", :page => pi) << ' '
        end
      end
      ret << ' ' << pager.page.to_s << ' '
      if pager.next_page
        ((pager.page+1)..pager.num_pages).each do |pi|
          ret << ' ' << link_with_params("#{pi}", :page => pi) << ' '
        end
        ret << link_with_params('Next &gt;&gt;', :page => pager.next_page)
        ret << " "
        ret << link_with_params('Last &gt;|', :page => pager.num_pages)
      end
      ret << "</div>"
    end
  end

  def page_title
    @page_title || ""
  end

  def scale_image_tag(picture, options = {})
    if picture
      # raise options.to_yaml
      image_tag(picture.url(options[:width], options[:height]), options.merge({:alt => picture.image_alt, :title => picture.image_alt}))
    else
      image_tag("clear.gif", options)
    end
  end

  def thumbnail_tag(picture, options = {})
    link_to(scale_image_tag(picture, options.merge({:border => 0})), "/settings/view_image/#{picture.id}", :popup => ["_blank", "width=#{picture.width+15},height=#{picture.height + 10}"])
  end

  def lightbox_image_tag(picture, options = {})
    @include_lightbox_script = true
    if picture.type == String
      link_to image_tag(picture, :width => options[:width], :height => options[:height]), "images/#{picture}", :rel => "lytebox[#{options[:group]}]", :title => options[:alt], :class => options[:class], :style => options[:style]
    else
      link_to image_tag(picture.url(options[:width], options[:height]), options.merge({:alt => picture.image_alt, :title => picture.image_alt})), picture.url, :rel => 'lytebox', :title => picture.image_alt, :class => options[:class], :style => options[:style]
    end
  end

  def admin_table(locals_in)
    defaults = {:edit_action => 'edit', :list_action => 'list', :delete_action => 'delete', :order_action => 'order', :view_action => false}
    columns = locals_in[:columns].map do |column|
      if column.kind_of?(String) or column.kind_of?(Symbol)
        column = column.to_s
        if column.split("_").last == "id"
          cname = column.gsub("_id", "")
          # here, possibly change the middle entry to say cname, and redefine the printing method of the object?
          [cname.split("_").map{|w| w.capitalize}.join(" "), lambda{|o| o.send(cname) ? o.send(cname).name : ""}, column]
        else
          [column.split("_").map{|w| w.capitalize}.join(" "), column, column]
        end
      else
        column
      end
    end
    locals = defaults.merge(locals_in).merge(:columns => columns)
    render :partial => "shared/admin_table", :locals => locals
  end

  def last_updated_field(obj)
    if obj.last_updated
    "<acronym title=\"updated by: #{obj.updated_by}\">#{(obj.last_updated.strftime("%d %B"))}</acronym>"
    end
  end

  def link_with_params(text, options={}, html_options={})
    link_to(text, params.merge(options), html_options)
  end

  def copyright_message(start_year)
    end_year = ""
    if start_year != Date.today.year
      end_year = " - " + Date.today.year.to_s
    end
    "&copy; T Media Ltd #{start_year}" + end_year
  end

  def short_text_date(date)
    if date
      date.day.to_s + " " + ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][date.month - 1] + " " + date.year.to_s
    else
      ""
    end
  end

  def month_name(month)
    ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][month]
  end

  def link_to_highlight(name, options = { }, html_options = { })
    if params[:action] =~ options[:action]
      html_options.merge! :class => "on"
    end
    link_to name, options, html_options
  end

  def module_links(name, controller, link_list = [["See All", "list"],["Add New", "new"]])
    output = ""
    output << link_to(name, {:controller => controller}, {:class => "main"})
    link_list.each do |link|
      output << link_to(link[0], {:controller => controller, :action => link[1]})
    end
    output
  end

  def crop_image_tag(picture, crop_number = 1, options = {})
    if picture
      if picture.crop_url(crop_number)
        image_tag(picture.crop_url(crop_number), options.merge({:alt => picture.image_alt, :title => picture.image_alt}))
      else
        if options[:width]
          scale_image_tag(picture, options.merge({:alt => picture.image_alt, :title => picture.image_alt}).delete_if{|k,v| k == 'height'})
        else
          scale_image_tag(picture, options.merge({:alt => picture.image_alt, :title => picture.image_alt}))
        end
      end
    else
      image_tag("clear.gif", options)
    end
  end

  def hide_flash?
    @hide_flash
  end

  def hide_flash
    @hide_flash = true
  end

  def link_to_remove_fields(name, f)
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)")
  end

  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, h("add_fields(this, \"#{association}\", \"#{escape_javascript(fields)}\")"))
  end

  def brev(text, max_length)
    if text.length > max_length
      "#{text[0...(max_length)] + "..."}"
    else
      text
    end
  end

end
