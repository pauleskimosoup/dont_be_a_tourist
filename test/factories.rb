###
# Admins

Factory.sequence :username do |n|
  "admin_#{n}"
end

Factory.define :admin do |u|
  u.name { Factory.next(:username)}
  u.password 'password'
  u.password2 'password'
  u.email 'test@tmedia.co.uk'
end

###
# Features

Factory.sequence :feature_name do |n|
  "Feature #{n.ordinalize}"
end

Factory.define :feature do |f|
  f.name { Factory.next(:feature_name)}
  f.controller { |u| u.name.gsub(" ", "").underscore + "_admin"}
end
