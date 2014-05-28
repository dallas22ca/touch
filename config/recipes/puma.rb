set_default(:puma_user) { user }
set_default(:puma_pid) { "#{shared_path}/sockets/puma.pid" }
set_default(:puma_state) { "#{shared_path}/sockets/puma.state" }
set_default(:puma_sock) { "unix://#{shared_path}/sockets/puma.sock" }
set_default(:puma_ctl) { "unix://#{shared_path}/sockets/pumactl.sock" }
set_default(:puma_log) { "#{shared_path}/log/puma.log" }
set_default(:puma_threads) { "4:16"}
set_default(:puma_workers, 3)

namespace :puma do
  desc "Setup puma initializer and app configuration"
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "puma_init.erb", "/tmp/puma_init"
    run "chmod +x /tmp/puma_init"
    run "#{sudo} mv /tmp/puma_init /etc/init.d/puma_#{application}"
    run "#{sudo} update-rc.d -f puma_#{application} defaults"
  end
  after "deploy:setup", "puma:setup"
  
  task :do_restart do
    sleep 15
    puma.restart
  end
end
