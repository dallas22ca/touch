set_default(:faye_user) { user }
set_default(:faye_pid) { "#{current_path}/tmp/pids/faye.pid" }
set_default(:faye_ru) { "#{current_path}/faye.ru" }
set_default(:faye_port) { 9291 }

namespace :faye do
  desc "Setup Faye initializer"
  task :setup, roles: :app do
    template "faye_init.erb", "/tmp/faye_init"
    run "chmod +x /tmp/faye_init"
    run "#{sudo} mv /tmp/faye_init /etc/init.d/faye_#{application}"
    run "#{sudo} update-rc.d -f faye_#{application} defaults"
  end
  after "deploy:setup", "faye:setup"

  task :start do
    run %Q{cd #{current_path}; thin start -R faye.ru --ssl  --ssl-key-file "/etc/ssl/certs/www.daljs.org/domain.key"  --ssl-cert-file "/etc/ssl/certs/www.daljs.org/ssl.crt" -p 9291 -d}
  end
  # after "deploy:start", "faye:start"
  
  task :restart do
    stop
    start
  end
  # after "deploy:restart", "faye:restart"
  
  
  task :stop do
    run "ps -ef | grep thin | grep -v grep | awk '{print $2}' | xargs kill || echo 'no process with name #{name} found'"
  end
  # after "deploy:start", "faye:start"
end