module UserHelper

end

class UserMailer < ActionMailer::Base

  def forgotten_password(user, new_password)
    @recipients = user.email
    @from = SiteProfile.first.email
    @subject = "Your Login Information"
    @body[:user] = user
    @body[:new_password] = new_password
    content_type "text/html" 
  end
  
end
