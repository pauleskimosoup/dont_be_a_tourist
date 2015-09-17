class NewsletterSignUpMailer < ActionMailer::Base

  def new_sign_up(contact)
    recipients "info@dontbeatourist.co.uk"
    from "Dont Be A Tourist <info@dontbeatourist.co.uk>"
    subject "New Email Sign Up"
    sent_on Time.now
    body :contact => contact
  end

end