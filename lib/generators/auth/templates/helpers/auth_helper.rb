module <%= class_name %>Helper

end

class <%= class_name %>Mailer < ActionMailer::Base

  def forgotten_password(<%= singular_name %>, new_password)
    @recipients = <%= singular_name %>.email
    @from = SiteProfile.first.email
    @subject = "Your Login Information"
    @body[:<%= singular_name %>] = <%= singular_name %>
    @body[:new_password] = new_password
    content_type "text/html" 
  end
  
end
