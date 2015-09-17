class AuthGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      m.directory "app/controllers"
      m.template "controllers/auth_controller.rb", "app/controllers/#{file_name}_controller.rb"
      m.template "controllers/auth_admin_controller.rb", "app/controllers/#{file_name}_admin_controller.rb"
      
      m.directory "app/helpers"
      m.template "helpers/auth_helper.rb", "app/helpers/#{file_name}_helper.rb"
      
      m.directory "app/models"
      m.template "models/auth.rb", "app/models/#{file_name}.rb"
      
      m.directory "app/views/#{file_name}"
      m.template "views/auth/_errors.html.erb", "app/views/#{file_name}/_errors.html.erb"
      m.template "views/auth/_form.html.erb", "app/views/#{file_name}/_form.html.erb"
      m.template "views/auth/_login.html.erb", "app/views/#{file_name}/_login.html.erb"
      m.template "views/auth/edit.html.erb", "app/views/#{file_name}/edit.html.erb"
      m.template "views/auth/forgot.html.erb", "app/views/#{file_name}/forgot.html.erb"
      m.template "views/auth/home.html.erb", "app/views/#{file_name}/home.html.erb"
      m.template "views/auth/login.html.erb", "app/views/#{file_name}/login.html.erb"
      m.template "views/auth/new.html.erb", "app/views/#{file_name}/new.html.erb"
      
      m.directory "app/views/#{file_name}_admin"
      m.template "views/auth_admin/_form.html.erb", "app/views/#{file_name}_admin/_form.html.erb"
      m.template "views/auth_admin/edit.html.erb", "app/views/#{file_name}_admin/edit.html.erb"
      m.template "views/auth_admin/list.html.erb", "app/views/#{file_name}_admin/list.html.erb"
      m.template "views/auth_admin/new.html.erb", "app/views/#{file_name}_admin/new.html.erb"
      
      m.directory "app/views/#{file_name}_mailer"
      m.template "views/auth_mailer/forgotten_password.rhtml", "app/views/#{file_name}_mailer/forgotten_password.rhtml"
      
      m.migration_template "migrate/create_auth.rb", "db/migrate/", :migration_file_name => "create_#{file_name}"
    end
  end

end