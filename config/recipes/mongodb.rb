set_default(:mongodb_host, "localhost")
set_default(:mongodb_user) { application }
set_default(:mongodb_password) { Capistrano::CLI.password_prompt "MongoDB Password: " }
set_default(:mongodb_database) { "#{application}_#{rails_env}" }
set_default(:mongodb_pid) { "/var/run/mongodb/pidder.pid" }

namespace :mongodb do
  desc "Install the latest stable release of MongoDB."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10"
    run %Q{echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list}
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install mongodb-org"
    run "#{sudo} chkconfig mongod on"
    # NEED TO ADD USER
  end
  after "deploy:install", "mongodb:install"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mongoid.yml.erb", "#{shared_path}/config/mongoid.yml"
  end
  after "deploy:setup", "mongodb:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
  end
  after "deploy:finalize_update", "mongodb:symlink"
  
  %w[start stop restart].each do |command|
    desc "#{command} mongodb"
    task command, roles: :app do
      run "#{sudo} service mongod #{command}"
    end
  end
end
