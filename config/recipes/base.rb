def template(from, to)
  erb = File.read(File.expand_path("../templates/#{from}", __FILE__))
  put ERB.new(erb).result(binding), to
end

def set_default(name, *args, &block)
  set(name, *args, &block) unless exists?(name)
end

namespace :deploy do
  desc "Install everything onto the server"
  task :install do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install python-software-properties"
  end
  
  task :install_bundler, :roles => :app do
    run "type -P bundle &>/dev/null || { gem install bundler --no-rdoc --no-ri; }"
  end
  
  desc "Remove Unnecessary Dependancies"
  task :autoremove do
    run "#{sudo} apt-get -y autoremove"
  end
end

task :ip do
  p "ssh deployer@#{server_name} -#{rails_env}"
end