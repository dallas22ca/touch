namespace :bundler do
  desc "Install bundler"
  task :install, roles: :web do
    run "cd"
    run "touch ~/.gemrc"
    gemrc = <<-BASHRC
    gem: --no-ri --no-rdoc
    BASHRC
    put gemrc, "/tmp/gemrc"
    run "cat /tmp/gemrc ~/.gemrc > ~/.gemrc.tmp"
    run "mv ~/.gemrc.tmp ~/.gemrc"
    run "gem install bundler"
    run "gem install rails"
    run "rbenv rehash"
  end
  after "rbenv:install", "bundler:install"
end