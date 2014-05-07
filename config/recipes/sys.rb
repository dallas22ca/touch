namespace :sys do
  desc "Reboot"
  task :reboot do
    run "yes | #{sudo} reboot -h now"
  end
  
  desc "Shutdown"
  task :shutdown do
    run "yes | #{sudo} shutdown -h now"
    p "You must log in to Digital Ocean to start the server up."
  end
end
