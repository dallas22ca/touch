set_default(:sidekiq_pid) { "#{current_path}/tmp/pids/sidekiq.pid" }
set_default(:sidekiq_config) { "#{current_path}/config/sidekiq.yml" }
set_default(:sidekiq_log) { "#{shared_path}/log/sidekiq.log" }

namespace :sidekiq do
  task :restart, :roles => :app do
    stop
    sleep 5
    start
  end
  
  desc "Setup Sidekiq initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "sidekiq_init.erb", "/tmp/sidekiq_init"
    run "#{sudo} mv /tmp/sidekiq_init /etc/init.d/sidekiq_#{application}"
    run "#{sudo} update-rc.d sidekiq_#{application} defaults 99"
    run "#{sudo} chmod +x /etc/init.d/sidekiq_#{application}"
  end
  after "deploy:setup", "sidekiq:setup"
end