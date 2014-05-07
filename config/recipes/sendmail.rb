set_default :ruby_version, "2.0.0-p0"

namespace :sendmail do
  desc "Install Sendmail"
  task :install, roles: :app do
    run "#{sudo} apt-get update"
    run "#{sudo} apt-get -y install sendmail"
  end
  after "deploy:install", "sendmail:install"
  
  desc "Setup Sendmail"
  task :setup, roles: :app do
    # cd /etc/mail
    # sendmail.mc: define('SMART_HOST','your.isp.net')dnl
    # m4 sendmail.mc > sendmail.cf
    # service sendmail restart
    p "Sendmail setup is manual."
  end
  after "deploy:install", "sendmail:setup"
end
