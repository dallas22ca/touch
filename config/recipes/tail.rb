task :tail do
  ENV["LOGFILE"] ||= "*.log"
  run "tail -f #{current_path}/log/#{ENV["LOGFILE"]}" do |channel, stream, data|
    puts "#{data}"
    break if stream == :err
  end
end