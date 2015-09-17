class Feature < ActiveRecord::Base

  has_and_belongs_to_many :admins

  def initialize(*params)
    super(*params)
    if File.exists? "#{RAILS_ROOT}/app/views/shared/_admin_navigation.html.erb"
      #newschool
      replace_in_file "#{RAILS_ROOT}/app/views/shared/_admin_navigation.html.erb", "<!-- [NEWFEATURESUBNAV] -->",
      "<%= module_links '#{self.name}', :#{self.controller} %>\n<!-- [NEWFEATURESUBNAV] -->"

    else
      #oldschool
      replace_in_file("#{RAILS_ROOT}/config/admin_navigation.yml", "#[NEWFEATURESUBNAV]",
"        - link: {title: #{self.name}, controller: #{self.controller}, action: index}
          list: - {title: See All, controller: #{self.controller}, action: list}
                - {title: Add New, controller: #{self.controller}, action: new}
#[NEWFEATURESUBNAV]")
    end
  end

  def Feature.find_by_class_name(class_name)
    Feature.find(:all).select{|f| f.controller_class == class_name}[0]
  end

  def Feature.find_all_but_all
    Feature.find(:all).reject{|f| f.all? }
  end

  def controller_class
    self.controller.split("_").map(&:capitalize).join + "Controller"
  end

  def all?
    self == Feature.all_feature
  end

  def Feature.all_feature
    Feature.find_by_controller("all")
  end

  def replace_in_file(filename, old, new)
    text = ""
    File.open(filename, "r") do |f|
      text = f.read
    end
    File.open(filename, "w+") do |f|
      f.write(text.gsub(old, new))
    end
  end


end
