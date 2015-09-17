ActionController::Routing::Routes.draw do |map|
  map.resources :trip_groups, :only => [:show], :as => :trips

  map.connect "win", :controller => 'web', :action => 'win'
  map.connect "cheap-train-tickets", :controller => 'web', :action => 'cheap_train_tickets'
  map.connect "trip/search", :controller => 'trip', :action => 'search'
  map.connect "payment_notification/create", :controller => "payment_notification", :action => "create", :conditions => { :method => :post }
  map.connect "payment_notification/complete_payment", :controller => "payment_notification", :action => "complete_payment", :conditions => { :method => :post }

  map.resource :basket
  map.resources :university_contacts
  map.resources :newsletter_sign_ups
  map.resources :universities, :only => [:show]
  map.resources :feedbacks, :only => [:create]

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect '/image/dialog', :controller => 'image', :action => 'dialog'
  map.connect '/image/upload', :controller => 'image', :action => 'upload'
  map.connect '/image/insert/:id', :controller => 'image', :action => 'insert'
  map.connect '/image/:id/:width/:height', :controller => 'image', :action => 'index', :width => 0, :height => 0
  map.connect '/admin', :controller => 'login', :action => 'home'
  map.connect ':controller/:action'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'


  map.connect 'splash_page/:id', :controller => 'splash_page', :action => 'show'
  map.connect 'splash_page/redeem/:id', :controller => 'splash_page', :action => 'redeem'
  map.root :controller => "web"

  #this isn't great
  map.connect ':id', :controller => 'universities', :action => 'show'

end
