namespace :backup do
  task :db do
    if ENV.has_key?("filename")
      filename = ENV["filename"]
      ext = ".#{filename.split(".").last}"
    else
      time = Time.now
      ext = ".tar"
      filename = "backup-db-#{rails_env}-#{time.to_i}-#{time.strftime("%m-%d-%y")}#{ext}"
    end
    
    run "mkdir -p backups"
    run "mkdir -p apps/#{application}/current/public/backups"
    run "#{sudo} -u postgres pg_dump #{application}_#{rails_env} > backups/#{filename}"
    run "yes | cp backups/#{filename} apps/#{application}/current/public/backups"
    puts "Accessible to be downloaded at #{root_url}/backups/#{filename}"
  end
  
  task :files do
    time = Time.now
    ext = ".tar.gz"
    filename = "backup-files-#{rails_env}-#{time.to_i}-#{time.strftime("%m-%d-%y")}#{ext}"
    dir = "apps/#{application}/shared/public"
    run "mkdir -p backups"
    run "tar -zcvf backups/#{filename} #{dir}"
    run "yes | cp backups/#{filename} apps/#{application}/current/public/backups"
    puts "Accessible to be downloaded at #{root_url}/backups/#{filename}"
  end
end

namespace :restore do
  # cap st restore:db url=full_backup_file_url   ed st pr
  task :db do
    if ENV.has_key?("url")
      url = ENV["url"]
      ext = ".#{url.split(".").last}"
      time = Time.now
      newfile = "restore-db-#{rails_env}-#{time.to_i}-#{time.strftime("%m-%d-%y")}#{ext}"
  
      unicorn.stop
      sidekiq.stop
      run "mkdir -p restore"
      run "wget #{url} -O restore/#{newfile}"
      
      postgresql.drop_database
      run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
      
      run "#{sudo} -u postgres psql #{application}_#{rails_env} < restore/#{newfile}"
      unicorn.start
    else
      puts "Houston, we have a problem.\n Please provide a url that exists."
    end
  end
  
  # cap st restore:files url=full_backup_file_url 
  task :files do
    if ENV.has_key?("url")
      url = ENV["url"]
      ext = ".tar.gz"
      dir = "apps/#{application}/shared/public"
      time = Time.now
      newfile = "restore-files-#{rails_env}-#{time.to_i}-#{time.strftime("%m-%d-%y")}#{ext}"
      run "mkdir -p #{dir}"
      run "mkdir -p restore"
      run "wget #{url} -O restore/#{newfile}"
      run "tar -zxvf restore/#{newfile}"
    else
      puts "Houston, we have a problem.\n Please provide a url that exists."
    end
  end
  
  task :local do
    begin 
      if ENV.has_key?("url")
        config = YAML.load(ERB.new(File.read("config/database.yml")).result)["development"]
        url = ENV["url"]
        ext = ".#{url.split(".").last}"
        time = Time.now
        newfile = "restore-db-#{config["database"]}-#{time.to_i}-#{time.strftime("%m-%d-%y")}#{ext}"
        
        
        `mkdir -p restore`
        `wget #{url} -O restore/#{newfile}`
        `bundle exec rake db:drop`
        `bundle exec rake db:create`
        `#{sudo} -u #{config["username"]} psql #{config["database"]} < restore/#{newfile}`
        `rm -rf restore`
      else
        puts "Houston, we have a problem.\n Please provide a url that exists."
      end
    rescue
      puts "Stop rails s and foreman and run restore:local again. Install wget if not installed."
    end
  end
end