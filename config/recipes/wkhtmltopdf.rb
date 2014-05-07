namespace :wkhtmltopdf do
  desc "Install the latest release of ImageMagick and the MagickWand Dev Library"
  task :install, roles: :app do
    # 32bit: i386
    # 64bit: amd64
    version = "i386"
    
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install openssl build-essential xorg libssl-dev libxrender-dev libxext-dev libpq-dev libx11-dev wkhtmltopdf"
    run "wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.11.0_rc1-static-#{version}.tar.bz2"
    run "tar xvjf wkhtmltopdf-0.11.0_rc1-static-#{version}.tar.bz2"
    run "#{sudo} mv wkhtmltopdf-#{version} /usr/local/bin/wkhtmltopdf"
    run "#{sudo} chmod +x /usr/local/bin/wkhtmltopdf"
    run "#{sudo} rm wkhtmltopdf-0.11.0_rc1-static-#{version}.tar.bz2"
  end
  after "deploy:install", "wkhtmltopdf:install"
end

namespace :wkhtmltoimage do
  desc "Install the latest release of ImageMagick and the MagickWand Dev Library"
  task :install, roles: :app do
    # 32bit: i386
    # 64bit: amd64
    version = "i386"
    
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install openssl build-essential xorg libssl-dev libxrender-dev libxext-dev libpq-dev libx11-dev wkhtmltopdf"
    run "wget https://wkhtmltopdf.googlecode.com/files/wkhtmltoimage-0.11.0_rc1-static-#{version}.tar.bz2"
    run "tar xvjf wkhtmltoimage-0.11.0_rc1-static-#{version}.tar.bz2"
    run "#{sudo} mv wkhtmltoimage-#{version} /usr/local/bin/wkhtmltoimage"
    run "#{sudo} chmod +x /usr/local/bin/wkhtmltoimage"
    run "#{sudo} rm wkhtmltoimage-0.11.0_rc1-static-#{version}.tar.bz2"
  end
  after "deploy:install", "wkhtmltopdf:install"
end