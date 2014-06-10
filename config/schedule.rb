ENV["RAILS_ENV"] ||= "production"

set :output, "/home/deployer/apps/touch/current/log/cron.log"
job_type :script,  "cd /home/deployer/apps/touch/current && RAILS_ENV=:environment script/rails runner script/:task :output"
job_type :runner, "cd /home/deployer/apps/touch/current && rails runner -e :environment \":task\" :output"

every 1.day, at: "7:05 am" do
  runner "Message.deliver_overdue"
end

every 1.day, at: "12:05 pm" do
  runner "Message.deliver_overdue"
end

every 1.day, at: "7:05 pm" do
  runner "Message.deliver_overdue"
end