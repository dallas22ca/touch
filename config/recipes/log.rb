namespace :log do
  desc "Clear Logs"
  task :clear, roles: :app do
    run %Q{cd #{latest_release} && RAILS_ENV=#{rails_env} rake log:clear}
  end
end