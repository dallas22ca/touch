namespace :cache do
  task :clear, roles: :app do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rake cache:clear"
  end
end
