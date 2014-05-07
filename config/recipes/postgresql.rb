set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }
set_default(:postgresql_pid) { "/var/run/postgresql/9.2-main.pid" }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository -y ppa:pitti/postgresql"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql-9.2 libpq-dev postgresql-contrib-9.2"
  end
  after "deploy:install", "postgresql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with superuser password '#{postgresql_password}';"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
    run %Q{#{sudo} -u postgres psql -c "ALTER USER #{postgresql_user} WITH SUPERUSER;"}
    # run %Q{#{sudo} -u postgres psql -c "create extension if not exists hstore; "}
  end
  after "deploy:setup", "postgresql:create_database"
  
  desc "Drop database for this application."
  task :drop_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "drop database #{postgresql_database};"}
    run %Q{#{sudo} -u postgres psql -c "drop user #{postgresql_user};"}
  end

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"
  
  %w[start stop restart].each do |command|
    desc "#{command} postgresql"
    task command, roles: :app do
      run "#{sudo} service postgresql #{command}"
    end
  end
end
