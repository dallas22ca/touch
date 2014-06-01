load 'deploy/assets'

require "bundler/capistrano"
require 'sidekiq/capistrano'
# require "whenever/capistrano"
require 'puma/capistrano'

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :application, "touch"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false
set :workers, { '*' => 5 }
set :app_server, :puma

set :scm, "git"
set :repository, "git@github.com:dallas22ca/#{application}.git"

set :maintenance_template_path, File.expand_path("../recipes/templates/maintenance.html.erb", __FILE__)
set :whenever_command, "bundle exec whenever"

set :server_name, "95.85.29.240"
set :rails_env, "production"
set :branch, "master"
set :domains, ["app.oneattendance.com", "app.realtxn.com"]
set :root_url, "https://#{domains[0]}"
set :mem_total, 2000
set :mem_threshold, (mem_total * 0.75).round
server server_name, :web, :app, :db, primary: true
set :whenever_command, "bundle exec whenever"

Dir.glob("config/recipes/*.rb").each do |file|
  load file
end

before "deploy:migrate", "deploy:web:disable"
after "deploy:web:enable", "puma:do_restart"
after "deploy", "deploy:migrate"
after "deploy", "deploy:cleanup"
after "deploy:cleanup", "deploy:web:enable"
after "deploy:install", "deploy:autoremove"