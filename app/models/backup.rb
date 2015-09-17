class Backup < ActiveRecord::Base

  include TimeStampable
  include Tp2Mixin

  validates_presence_of :filename

  BACKUP_DIR = "#{RAILS_ROOT}/db/backups"

  def Backup.backup
    file_name = "#{BACKUP_DIR}/db_#{Date.today}_1.sql"
    backup = nil
    while File.exists?(file_name)
      split = file_name.split("_")
      file_name = split[0, split.length - 1].join("_") + "_" + (split[-1].to_i + 1).to_s + ".sql"
    end
    if system("mysqldump #{ActiveRecord::Base.configurations['development']['database']} -u #{ActiveRecord::Base.configurations['development']['username']} -p#{ActiveRecord::Base.configurations['development']['password']} > #{file_name.gsub(" ", '\ ')}")
      backup = Backup.new
      backup.filename = file_name
      backup
    end
  end

  def exists?
    File.exists?(self.filename)
  end


end
