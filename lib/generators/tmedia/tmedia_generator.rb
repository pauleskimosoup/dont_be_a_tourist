require 'ostruct'
class TmediaGenerator < Rails::Generator::NamedBase

  def manifest

    singular_name = file_name
    print_singular_name = singular_name.split("_").map{|w| w.capitalize}.join(" ")
    plural_name = @args.shift
    print_plural_name = plural_name.split("_").map{|w| w.capitalize}.join(" ")
    feature_name = @args.shift
    print_feature_name = feature_name.split("_").map{|w| w.capitalize}.join(" ")
    class_name = singular_name.split("_").map{ |w| w.capitalize}.join("")
    controller_name = feature_name.split("_").map{ |w| w.capitalize}.join("")

    @args = ["name:string"] + @args + ["display:boolean"]

    model_fields = @args.map{|arg| arg.split(":")}.map{|pair| OpenStruct.new(:name => pair[0], :field_type => pair[1])}

    Feature.create(:name => print_feature_name, :controller => feature_name + "_admin")
    assigns = {:model_fields => model_fields, :singular_name => singular_name, :plural_name => plural_name, :feature_name => feature_name, :print_singular_name => print_singular_name, :print_plural_name => print_plural_name, :print_feature_name => print_feature_name, :class_name => class_name, :field_names => model_fields.map(&:name), :controller_name => controller_name}

    record do |m|
      m.class_collisions class_name
      m.template "app/controllers/controller_template.rb" ,
      "app/controllers/#{ feature_name}_controller.rb",
      :assigns => assigns

      m.template "app/controllers/controller_admin_template.rb" ,
      "app/controllers/#{ feature_name}_admin_controller.rb",
      :assigns => assigns

      m.template "app/models/model_template.rb" ,
      "app/models/#{singular_name}.rb",
      :assigns => assigns

      m.directory File.join('app/views' , feature_name)
      m.template "app/views/template/list.html.erb" ,
      "app/views/#{ feature_name}/list.html.erb",
      :assigns => assigns

      m.template "app/views/template/show.html.erb" ,
      "app/views/#{feature_name}/show.html.erb",
      :assigns => assigns

      m.directory File.join('app/views' , feature_name + '_admin')
      m.template "app/views/template_admin/list.html.erb" ,
      "app/views/#{ feature_name}_admin/list.html.erb",
      :assigns => assigns

      m.template "app/views/template_admin/new.html.erb" ,
      "app/views/#{ feature_name}_admin/new.html.erb",
      :assigns => assigns

      m.template "app/views/template_admin/edit.html.erb" ,
      "app/views/#{ feature_name}_admin/edit.html.erb",
      :assigns => assigns

      m.template "app/views/template_admin/_subnav.html.erb" ,
      "app/views/#{ feature_name}_admin/_subnav.html.erb",
      :assigns => assigns

      m.template "app/views/template_admin/_form.html.erb" ,
      "app/views/#{ feature_name}_admin/_form.html.erb",
      :assigns => assigns.merge(:form_fields => create_form_fields(model_fields))

      tmedia_field_types = [["tinymce", "text"], ["summary", "text"], ["image", "integer"], ["document", "integer"], ["collection", "integer"], ["t_date_select", "date"]].map{|pair| OpenStruct.new(:name => pair[0], :field_type => pair[1])}
      args_for_model = @args.map do |arg|
        index = tmedia_field_types.map(&:name).index(arg.split(":").last)
        if index
          arg.split(":").first + ":" + tmedia_field_types[index].field_type
          else
          arg
        end
      end

      m.dependency 'model', [singular_name] + args_for_model + ["last_updated:datetime", "updated_by:string", "created_by:string"], :collision => :skip

    end
  end

  def create_form_fields(model_fields)
    model_fields.map do |mfield|
      OpenStruct.new(:name => mfield.name,
                     :field_type => convert_model_to_form(mfield.field_type))
    end
  end

  def convert_model_to_form(mfield_type)
    hash = {"image" => "comprehensive_image_field", "document" => "comprehensive_document_field", "boolean" => "check_box", "tinymce" => "tinymce_text_area", "text" => "text_area", "summary" => "summary_text_area", "integer" => "text_field", "float" => "text_field", "collection" => "default_collection_select", "t_date_select" => "t_date_select"}
    hash.default = "text_field"
    hash[mfield_type]
  end



end
