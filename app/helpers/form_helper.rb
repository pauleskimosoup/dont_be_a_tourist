module FormHelper
  def self.included(base)
    ActionView::Helpers::FormBuilder.instance_eval do 
      include FormBuilderMethods
    end
end

module FormBuilderMethods
  def tinymce_text_area(attribute)
    @template.text_area(@object_name, attribute, :cols => nil, :rows => nil, :class => "mceEditor")
  end

  def t_date_select(attribute)
    @template.calendar_date_select @object_name, attribute, :class => 'date_field'
  end

  def comprehensive_image_field(attribute, label="")
    attribute = attribute.to_s.gsub("_id", "")
    fd_name = (attribute.to_s+"_file_data").to_sym
    ia_name = (attribute.to_s+"_image_alt").to_sym
    r_name = (attribute.to_s+"_remove").to_sym
    if label.empty?
      label = attribute.to_s.split("_").map{|word| word.capitalize}.join(" ")
    end
    output = ""
    #    output += "<fieldset>\n"
    #    output += "<legend>#{label}</legend>\n"
    output += "<div class='group_block'><p><label for='#{fd_name}'>Add Image</label>\n"
    output += @template.file_field(@object_name, fd_name, :class=>'file')
    output += "</p>\n"
    output += "<p><label for='#{ia_name}'>Image Title</label>\n"
    output += @template.text_field(@object_name, ia_name)
    output += "</p></div>\n"
    if @object.send(("has_"+attribute.to_s+"?").to_sym)
      output += "<p>"+ @template.thumbnail_tag(@object.send(attribute), :height => 100)+"</p>\n"
      output += "<p><label for='#{r_name}'>Remove Image</label>\n"
      output += @template.check_box(@object_name, r_name, :class=>"checkbox")
      output += "</p>\n"
    end
    #   output += "</fieldset>\n"
    output
  end

  def comprehensive_document_field(attribute, label="")
    attribute = attribute.to_s.gsub("_id", "")
    fd_name = (attribute.to_s+"_file_data").to_sym
    de_name = (attribute.to_s+"_description").to_sym
    r_name = (attribute.to_s+"_remove").to_sym
    if label.empty?
      label = attribute.to_s.split("_").map{|word| word.capitalize}.join(" ")
    end
    output = ""
    #    output += "<fieldset>\n"
    #    output += "<legend>#{label}</legend>\n"
    output += "<div class='group_block'><p><label for='#{fd_name}'>#{label} File</label>\n"
    output += @template.file_field(@object_name, fd_name) + "</p>\n"
    output += "<p><label for='#{de_name}'>#{label} File Name</label>\n"
    output += @template.text_field(@object_name, de_name) + "</p></div>\n"
    if @object.send(("has_"+attribute.to_s+"?").to_sym)
      output += "<p><a href=\"#{@object.send(attribute).url}\">#{@object.send(attribute).filename}</a></p>\n"
      output += "<p><label for='#{r_name}'>Remove Document</label>\n"
      output += @template.check_box(@object_name, r_name, :class => "checkbox") + "</p>\n"
    end
    #   output += "</fieldset>\n"
    output
  end

  def summary_text_area(attribute)
    @template.text_area(@object_name, attribute, :class => "summary")
  end

  def check_box(attribute)
    # This will be here while we support IE6.
    @template.check_box(@object_name, attribute, :class => "checkbox")
  end

  def default_collection_select(attribute)
    @template.collection_select(@object_name, attribute, attribute.to_s.gsub("_id", "").camelcase.constantize.find(:all, :order => "name asc"), :id, :name)
  end
  
  def tag_field(attribute, interface = :full, label = "Add Tag")
    output = ""
    add = [:add, :dropdown_add].include? interface
    vertical = [:add, :minimal].include? interface
    dropdown = [:dropdown, :dropdown_add].include? interface
    if interface == :full
      output << @template.text_field(@object_name, attribute)
    elsif dropdown
      output << @template.collection_select(@object_name, attribute, @object.tag_array, :to_s, :to_s, { :class => "select"}, { :class => "select"}) << "<br />"
    else
      output << @template.hidden_field(@object_name, attribute)
    end
    unless dropdown
      tag_links = []
      @object.class.all_tags_array.each do |tag|

        tag_links << @template.link_to_function(tag, "tag_swap('#{tag}', '#{@object.class.to_s.underscore}_#{attribute}')", :id => "#{tag}_#{@object.class.to_s.underscore}_#{attribute}")
        tag_links << "<br />" if vertical
      end
      output << "<p#{" class=\"v_tags\"" if vertical}>" << tag_links.join(" ") << "</p>"
    end
    if add
      output << @template.label("#{attribute}_add", label + ":")
      output << @template.text_field("#{attribute}_add", :class => "tag_add")
    end
    return output
    end

end

end
