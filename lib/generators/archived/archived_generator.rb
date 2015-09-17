class ArchivedGenerator < Rails::Generator::NamedBase

  def manifest

    singular_name = file_name
    print_singular_name = singular_name.split("_").map{|w| w.capitalize}.join(" ")
    plural_name = @args[0]
    print_plural_name = plural_name.split("_").map{|w| w.capitalize}.join(" ")
    feature_name = @args[1]
    controller_name = plural_name.split("_").map{ |w| w.capitalize}.join("")
    class_name = singular_name.split("_").map{ |w| w.capitalize}.join("")
    controller_name = feature_name.split("_").map{ |w| w.capitalize}.join("")

    record do |m|



      m.dependency 'tmedia', [singular_name, plural_name, feature_name] + ["summary:text", "body:tinymce", "picture1_id:image", "date:t_date_select"], :collision => :skip

      m.class_collisions class_name

      m.template "app/controllers/controller_template.rb" ,
      "app/controllers/#{feature_name}_controller.rb",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name, :controller_name => controller_name}, :collision => :force

      m.template "app/controllers/controller_admin_template.rb" ,
      "app/controllers/#{feature_name}_admin_controller.rb",
      :assigns => {:print_name => print_singular_name, :singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name, :controller_name => controller_name}, :collision => :force

      m.template "app/models/model_template.rb" ,
      "app/models/#{singular_name}.rb",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.directory File.join('app/views' , file_name)

      m.template "app/views/template/list.html.erb" ,
      "app/views/#{feature_name}/list.html.erb",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.template "app/views/template/show.html.erb" ,
      "app/views/#{feature_name}/show.html.erb",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.template "app/views/template/_navigation.rhtml" ,
      "app/views/#{feature_name}/_navigation.rhtml",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.template "app/views/template/_summary.rhtml" ,
      "app/views/#{feature_name}/_summary.rhtml",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.template "app/views/template/_year.rhtml" ,
      "app/views/#{feature_name}/_year.rhtml",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

      m.template "app/views/template/ajax_year.rhtml" ,
      "app/views/#{feature_name}/ajax_year.rhtml",
      :assigns => {:singular_name => singular_name, :print_singular_name => print_singular_name, :plural_name => plural_name, :print_plural_name => print_plural_name, :feature_name => feature_name}, :collision => :force

    end
  end

end
