namespace :server do
  desc 'Restart the live server'
  task :restart do
    system 'pkill -9 dispatch.fcgi'
    system 'pkill -9 dispatch.fcgi'
  end
end

namespace :db do
  desc 'Load the schema and db/data.sql'
  task :initialise => ["db:schema:load", "db:data:load"] do
    #nothing
  end

  namespace :data do

    desc 'Dump local data into an sql file'
    task :dump do

      require 'yaml'

      db_config = YAML.load_file("config/database.yml")["development"]
      username = db_config["username"]
      password = db_config["password"]
      database = db_config["database"]


      system("mysqldump -u #{username} -p#{password} --ignore-table=#{ database }.schema_migrations #{database} -c -n -t > db/data.sql")
    end

    desc 'Load db/data.sql into database'
    task :load do

      require 'yaml'

      db_config = YAML.load_file("config/database.yml")["development"]
      username = db_config["username"]
      password = db_config["password"]
      database = db_config["database"]


      system("mysql -u #{username} -p#{password} #{database} < db/data.sql")
    end


  end
end
