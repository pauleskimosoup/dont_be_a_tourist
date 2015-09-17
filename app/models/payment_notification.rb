class PaymentNotification < ActiveRecord::Base
  
  belongs_to :booking
  serialize :params
 
end
