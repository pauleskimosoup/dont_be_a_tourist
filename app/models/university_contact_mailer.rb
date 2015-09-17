class UniversityContactMailer < ActionMailer::Base

  def new_contact(university_contact)
    recipients "info@dontbeatourist.co.uk"
    from "Dont Be A Tourist <info@dontbeatourist.co.uk>"
    subject "New University Contact Sign Up"
    sent_on Time.now
    body :university_contact => university_contact
  end

end
