namespace :cron do
  desc "Start cron"
  task :start, roles: :app do
    run "#{sudo} service cron start"
  end
  
  desc "Stop cron"
  task :stop, roles: :app do
    run "#{sudo} service cron stop"
  end
  
  desc "Restart cron"
  task :restart, :roles => :app do
    run "#{sudo} service cron restart"
  end
  # after "deploy", "cron:restart"
end